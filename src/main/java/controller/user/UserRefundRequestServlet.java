package controller.user;

import dao.DAOFactory;
import dao.OrderDAO;
import dao.RefundDAO;
import controller.utils.RedirectUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.enums.OrderStatus;
import model.enums.PaymentStatus;
import model.order.Order;
import model.refund.RefundRequest;
import model.user.User;
import service.EcommerceEmailService;
import service.NotificationService;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 3 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024
)
@WebServlet("/refund-request")
public class UserRefundRequestServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(RedirectUtils.toLoginWithRedirect(request, "/don-hang"));
            return;
        }

        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String reason = trimOrNull(request.getParameter("reason"));
            String receiveMethod = trimOrNull(request.getParameter("receiveMethod"));
            String accountHolder = trimOrNull(request.getParameter("accountHolder"));
            String accountNumber = trimOrNull(request.getParameter("accountNumber"));
            String note = trimOrNull(request.getParameter("note"));
            Part qrImagePart = request.getPart("qrImage");
            boolean hasQrImage = qrImagePart != null && qrImagePart.getSize() > 0;

            if (reason == null || receiveMethod == null || accountHolder == null ||
                    (accountNumber == null && !hasQrImage) ||
                    !"bank".equals(receiveMethod)) {
                setMessage(session, "Vui lòng nhập đầy đủ thông tin hoàn tiền.", "danger");
                response.sendRedirect(request.getContextPath() + "/don-hang");
                return;
            }

            OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
            RefundDAO refundDAO = DAOFactory.getInstance().getRefundDAO();
            Order order = orderDAO.getOrderById(orderId);
            RefundRequest existingRefund = refundDAO.getLatestRefundByOrderId(orderId);
            boolean completingPendingInfo = canCompletePendingInfoRefund(order, user.getId(), existingRefund);

            if (!completingPendingInfo && !canCreateRefundRequest(order, user.getId(), refundDAO)) {
                setMessage(session, "Đơn hàng này chưa đủ điều kiện yêu cầu hoàn tiền.", "danger");
                response.sendRedirect(request.getContextPath() + "/don-hang");
                return;
            }

            String qrImageUrl = saveQrImage(qrImagePart);

            RefundRequest refund = new RefundRequest();
            if (completingPendingInfo) {
                refund.setId(existingRefund.getId());
            }
            refund.setOrderId(order.getId());
            refund.setUserId(user.getId());
            refund.setAmount(order.getTotalAmount());
            refund.setReason(reason);
            refund.setReceiveMethod(receiveMethod);
            refund.setAccountHolder(accountHolder);
            refund.setAccountNumber(accountNumber);
            refund.setQrImageUrl(qrImageUrl);
            refund.setNote(note);

            boolean success = completingPendingInfo
                    ? refundDAO.completePendingInfoRefund(refund)
                    : refundDAO.createRefundRequest(refund);
            if (success) {
                NotificationService notificationService = new NotificationService();
                notificationService.notifyRefundRequested(order, completingPendingInfo);
                notificationService.notifyAdminRefundRequested(order, completingPendingInfo);
                EcommerceEmailService emailService = new EcommerceEmailService();
                emailService.sendRefundRequestedToUser(user, order);
                emailService.sendRefundRequestedToAdmin(order);
            }
            setMessage(session,
                    success ? "Yêu cầu hoàn tiền đã được gửi. Shop sẽ xử lý thủ công trong thời gian sớm nhất."
                            : "Không thể gửi yêu cầu hoàn tiền. Vui lòng thử lại sau.",
                    success ? "success" : "danger");
        } catch (Exception e) {
            e.printStackTrace();
            setMessage(session, "Đã có lỗi xảy ra khi gửi yêu cầu hoàn tiền.", "danger");
        }

        response.sendRedirect(request.getContextPath() + "/don-hang");
    }

    private boolean canCreateRefundRequest(Order order, int userId, RefundDAO refundDAO) {
        if (order == null || order.getUserId() != userId) {
            return false;
        }
        return order.getStatus() == OrderStatus.CANCELLED
                && isPaidOnlineOrder(order)
                && !refundDAO.hasOpenRefundRequest(order.getId());
    }

    private boolean canCompletePendingInfoRefund(Order order, int userId, RefundRequest refund) {
        return order != null
                && order.getUserId() == userId
                && isPaidOnlineOrder(order)
                && order.getStatus() == OrderStatus.DELIVERY_FAILED
                && refund != null
                && refund.getUserId() == userId
                && refund.getOrderId() == order.getId()
                && "pending_info".equals(refund.getStatus());
    }

    private boolean isPaidOnlineOrder(Order order) {
        return order.getPaymentStatus() == PaymentStatus.PAID
                && order.getPaymentMethod() != null
                && !"cod".equalsIgnoreCase(order.getPaymentMethod());
    }

    private String trimOrNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void setMessage(HttpSession session, String message, String type) {
        session.setAttribute("msg", message);
        session.setAttribute("msgType", type);
    }

    private String saveQrImage(Part part) throws IOException {
        if (part == null || part.getSize() == 0) {
            return null;
        }

        String contentType = part.getContentType();
        if (contentType == null || !contentType.toLowerCase().startsWith("image/")) {
            throw new IOException("Refund QR file must be an image");
        }

        String submitted = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String ext = "";
        int dotIndex = submitted.lastIndexOf('.');
        if (dotIndex >= 0) {
            ext = submitted.substring(dotIndex);
        }

        String relativeDir = "assets/images/refunds";
        String uploadPath = getServletContext().getRealPath("") + File.separator +
                relativeDir.replace("/", File.separator);
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String fileName = "refund_qr_" + System.currentTimeMillis() + "_" + UUID.randomUUID() + ext;
        part.write(uploadPath + File.separator + fileName);
        return relativeDir + "/" + fileName;
    }
}

