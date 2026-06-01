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
import model.user.User;
import controller.utils.PaymentResult;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.sql.Timestamp;
import java.time.LocalDateTime;

@WebServlet(urlPatterns = {
        "/thanh-toan-qr",
        "/thanh-toan-tiep",
        "/payment-status",
        "/payos-webhook",
        "/payos-return",
        "/payos-cancel",
        "/payos-confirm-webhook"
})
public class PaymentServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/thanh-toan-qr".equals(path)) {
            showPaymentQrPage(request, response);
        } else if ("/thanh-toan-tiep".equals(path)) {
            continuePayment(request, response);

        } else if ("/payment-status".equals(path)) {
            checkPaymentStatus(request, response);

        } else if ("/payos-return".equals(path)) {
            handlePayosReturn(request, response);

        } else if ("/payos-cancel".equals(path)) {
            handlePayosCancel(request, response);

        } else if ("/payos-confirm-webhook".equals(path)) {
            confirmPayosWebhook(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/payos-webhook".equals(path)) {
            handlePayosWebhook(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void showPaymentQrPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
                return;
            }

            int orderId = Integer.parseInt(request.getParameter("orderId"));

            OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
            PaymentTransactionDAO txDAO = DAOFactory.getInstance().getPaymentTransactionDAO();

            Order order = orderDAO.getOrderById(orderId);

            if (order == null || order.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/don-hang");
                return;
            }
            if (order.getPaymentStatus() == PaymentStatus.PAID) {
                response.sendRedirect(request.getContextPath() + "/hoa-don?id=" + orderId);
                return;
            }

            PaymentTransaction payment = txDAO.getByOrderId(orderId);
            if (payment == null) {
                response.sendRedirect(request.getContextPath() + "/don-hang");
                return;
            }

            request.setAttribute("order", order);
            request.setAttribute("payment", payment);

            request.getRequestDispatcher("/cart/thanh-toan-qr.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/don-hang");
        }
    }

    private void checkPaymentStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        Map<String, Object> data = new HashMap<>();

        try {
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            if (user == null) {
                data.put("paymentStatus", "UNAUTHORIZED");
                response.getWriter().write(gson.toJson(data));
                return;
            }

            int orderId = Integer.parseInt(request.getParameter("orderId"));

            OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
            Order order = orderDAO.getOrderById(orderId);

            if (order == null || order.getUserId() != user.getId()) {
                data.put("paymentStatus", "NOT_FOUND");
                response.getWriter().write(gson.toJson(data));
                return;
            }
            PaymentTransactionDAO txDAO = DAOFactory.getInstance().getPaymentTransactionDAO();
            PaymentTransaction payment = txDAO.getByOrderId(orderId);

            if (order.getPaymentStatus() == PaymentStatus.PENDING
                    && payment != null
                    && "pending".equalsIgnoreCase(payment.getTransactionStatus())
                    && payment.getExpiredAt() != null
                    && payment.getExpiredAt().before(new Timestamp(System.currentTimeMillis()))) {

                txDAO.markExpiredById(payment.getId());
                orderDAO.updatePaymentStatus(orderId, PaymentStatus.EXPIRED);

                data.put("paymentStatus", "EXPIRED");
                response.getWriter().write(gson.toJson(data));
                return;
            }

            data.put("paymentStatus", order.getPaymentStatus().toString());

        } catch (Exception e) {
            data.put("paymentStatus", "ERROR");
        }

        response.getWriter().write(gson.toJson(data));
    }

    private void confirmPayosWebhook(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        String result = PaymentUtils.confirmPayosWebhook();

        response.getWriter().write(result);
    }

    private void handlePayosReturn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String orderId = request.getParameter("orderId");

        if (orderId != null && !orderId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/thanh-toan-qr?orderId=" + orderId);
        } else {
            response.sendRedirect(request.getContextPath() + "/don-hang");
        }
    }

    private void handlePayosCancel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String orderId = request.getParameter("orderId");

        if (orderId != null && !orderId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/hoa-don?id=" + orderId);
        } else {
            response.sendRedirect(request.getContextPath() + "/don-hang");
        }
    }

    private void handlePayosWebhook(HttpServletRequest request, HttpServletResponse response)
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

            boolean validSignature = PaymentUtils.verifyPayosWebhook(json);

            if (!validSignature) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid signature");
                return;
            }

            String code = json.has("code") ? json.get("code").getAsString() : "";
            boolean success = json.has("success") && json.get("success").getAsBoolean();

            if (!"00".equals(code) || !success) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("OK");
                return;
            }

            JsonObject data = json.getAsJsonObject("data");

            String providerOrderId = data.get("orderCode").getAsString();
            long paidAmount = data.get("amount").getAsLong();

            OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
            PaymentTransactionDAO txDAO = DAOFactory.getInstance().getPaymentTransactionDAO();

            PaymentTransaction tx = txDAO.getByProviderOrderId(providerOrderId);

            if (tx == null) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("OK");
                return;}

            Order order = orderDAO.getOrderById(tx.getOrderId());

            if (order == null) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("OK");
                return;
            }

            if (order.getPaymentStatus() == PaymentStatus.PAID
                    || "paid".equalsIgnoreCase(tx.getTransactionStatus())) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("OK");
                return;
            }

            long expectedAmount = Math.round(order.getTotalAmount());

            if (expectedAmount != paidAmount) {
                System.out.println("Sai số tiền payOS. orderId=" + order.getId()
                        + ", providerOrderId=" + providerOrderId
                        + ", expected=" + expectedAmount
                        + ", paid=" + paidAmount);

                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("OK");
                return;
            }

            orderDAO.updatePaymentStatus(order.getId(), PaymentStatus.PAID);
            txDAO.markPaidByProviderOrderId(providerOrderId, rawBody);

            System.out.println("Đã cập nhật PAID cho orderId = " + order.getId()
                    + ", providerOrderId = " + providerOrderId);

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("OK");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Webhook error");
        }
    }
    private void continuePayment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
                return;
            }

            int orderId = Integer.parseInt(request.getParameter("orderId"));

            OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
            PaymentTransactionDAO txDAO = DAOFactory.getInstance().getPaymentTransactionDAO();

            Order order = orderDAO.getOrderById(orderId);

            if (order == null || order.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/don-hang");
                return;
            }

            if (order.getPaymentStatus() == PaymentStatus.PAID) {
                response.sendRedirect(request.getContextPath() + "/hoa-don?id=" + orderId);
                return;
            }

            if ("cod".equalsIgnoreCase(order.getPaymentMethod())) {
                response.sendRedirect(request.getContextPath() + "/hoa-don?id=" + orderId);
                return;
            }

            if (order.getStatus() != null && !"PENDING".equalsIgnoreCase(order.getStatus().toString())) {
                response.sendRedirect(request.getContextPath() + "/hoa-don?id=" + orderId);
                return;
            }

            PaymentTransaction oldTx = txDAO.getByOrderId(orderId);

            if (oldTx != null
                    && "pending".equalsIgnoreCase(oldTx.getTransactionStatus())
                    && oldTx.getExpiredAt() != null
                    && oldTx.getExpiredAt().after(new Timestamp(System.currentTimeMillis()))) {

                response.sendRedirect(request.getContextPath() + "/thanh-toan-qr?orderId=" + orderId);
                return;
            }

            if (oldTx != null && "pending".equalsIgnoreCase(oldTx.getTransactionStatus())) {
                txDAO.markExpiredById(oldTx.getId());
                orderDAO.updatePaymentStatus(orderId, PaymentStatus.EXPIRED);
            }

            PaymentResult res = "bank".equalsIgnoreCase(order.getPaymentMethod())
                    ? PaymentUtils.createPayosPayment(order)
                    : PaymentUtils.createMomoPayment(order);

            if (res == null) {
                response.sendRedirect(request.getContextPath() + "/hoa-don?id=" + orderId);
                return;
            }

            PaymentTransaction tx = new PaymentTransaction();
            tx.setOrderId(orderId);
            tx.setPaymentMethod(order.getPaymentMethod());
            tx.setProvider(res.getProvider());
            tx.setRequestId(res.getRequestId());
            tx.setProviderOrderId(res.getProviderOrderId());
            tx.setAmount(order.getTotalAmount());
            tx.setQrCodeUrl(res.getQrCodeUrl());
            tx.setPayUrl(res.getPayUrl());
            tx.setDeeplink(res.getDeeplink());
            tx.setTransactionStatus("pending");
            tx.setExpiredAt(Timestamp.valueOf(LocalDateTime.now().plusMinutes(2)));

            txDAO.create(tx);
            orderDAO.updatePaymentStatus(orderId, PaymentStatus.PENDING);

            response.sendRedirect(request.getContextPath() + "/thanh-toan-qr?orderId=" + orderId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/don-hang");
        }
    }
}