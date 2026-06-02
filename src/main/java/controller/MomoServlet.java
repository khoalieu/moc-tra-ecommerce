package controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import controller.utils.PaymentUtils;
import dao.DAOFactory;
import dao.OrderDAO;
import dao.PaymentTransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.enums.PaymentStatus;
import model.order.Order;
import model.payment.PaymentTransaction;

import java.io.BufferedReader;
import java.io.IOException;

@WebServlet(urlPatterns = {"/momo-ipn", "/momo-return"})
public class MomoServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/momo-return".equals(path)) {
            handleMomoReturn(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/don-hang");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/momo-ipn".equals(path)) {
            handleMomoIpn(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleMomoReturn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String orderNumber = request.getParameter("orderId");

            if (orderNumber == null || orderNumber.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/don-hang");
                return;
            }

            OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
            Integer orderId = orderDAO.getOrderIdByOrderNumber(orderNumber);

            if (orderId != null) {
                response.sendRedirect(request.getContextPath() + "/thanh-toan-qr?orderId=" + orderId);
            } else {
                response.sendRedirect(request.getContextPath() + "/don-hang");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/don-hang");
        }
    }

    private void handleMomoIpn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        StringBuilder body = new StringBuilder();

        try (BufferedReader reader = request.getReader()) {
            String line;

            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }

        String rawBody = body.toString();

        try {
            JsonObject json = gson.fromJson(rawBody, JsonObject.class);

            boolean validSignature = PaymentUtils.verifyMomoIpnSignature(json);

            if (!validSignature) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid signature");
                return;
            }

            String orderNumber = json.get("orderId").getAsString();
            int resultCode = json.get("resultCode").getAsInt();
            long paidAmount = json.get("amount").getAsLong();

            PaymentTransactionDAO txDAO = DAOFactory.getInstance().getPaymentTransactionDAO();
            OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();

            PaymentTransaction tx = txDAO.getByProviderOrderId(orderNumber);

            if (tx == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Transaction not found");
                return;
            }

            Order order = orderDAO.getOrderById(tx.getOrderId());

            if (order == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Order not found");
                return;
            }
            if (order.getPaymentStatus() == PaymentStatus.PAID
                    || "paid".equalsIgnoreCase(tx.getTransactionStatus())) {
                response.setStatus(HttpServletResponse.SC_NO_CONTENT);
                return;
            }

            long expectedAmount = Math.round(order.getTotalAmount());

            if (expectedAmount != paidAmount) {
                System.out.println("Sai số tiền MoMo. orderId=" + order.getId()
                        + ", expected=" + expectedAmount
                        + ", paid=" + paidAmount);

                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid amount");
                return;
            }

            if (resultCode == 0) {
                txDAO.markPaidByProviderOrderId(orderNumber, rawBody);
                orderDAO.updatePaymentStatus(tx.getOrderId(), PaymentStatus.PAID);
                System.out.println("Đã cập nhật PAID cho orderId = " + tx.getOrderId());
            } else {
                txDAO.updateStatusByProviderOrderId(orderNumber, "failed", rawBody);
                orderDAO.updatePaymentStatus(tx.getOrderId(), PaymentStatus.FAILED);
                System.out.println("MoMo thanh toán thất bại cho orderId = " + tx.getOrderId());
            }
            response.setStatus(HttpServletResponse.SC_NO_CONTENT);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("IPN error");
        }
    }
}