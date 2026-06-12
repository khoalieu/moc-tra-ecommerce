package service;

import controller.utils.EmailService;
import dao.DAOFactory;
import model.order.Order;
import model.product.Product;
import model.product.ProductVariant;
import model.refund.RefundRequest;
import model.user.User;

import java.text.DecimalFormat;
import java.util.List;
import java.util.concurrent.CompletableFuture;

public class EcommerceEmailService {
    private static final String SHOP_NAME = "Moc Tra";
    private static final DecimalFormat MONEY_FORMAT = new DecimalFormat("#,###");

    public void sendOrderCreatedToUser(User user, Order order) {
        if (user == null || order == null) {return;}
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String body = "Xin chao " + displayCustomerName(user) + ",\n\n"
                + "Don hang " + code + " cua ban da duoc tao thanh cong.\n"
                + "Tong tien: " + formatMoney(order.getTotalAmount()) + "\n"
                + "Cam on ban da mua hang tai " + SHOP_NAME + ".";
        sendToUser(user, "Dat hang thanh cong - " + code, body);
    }

    public void sendOrderCancelledToUser(User user, Order order) {
        if (user == null || order == null) {return;}
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String body = "Xin chao " + displayCustomerName(user) + ",\n\n"
                + "Don hang " + code + " da bi huy.\n"
                + "Ban co the xem chi tiet don hang trong tai khoan cua minh.";
        sendToUser(user, "Don hang da bi huy - " + code, body);
    }

    public void sendOrderCompletedToUser(User user, Order order) {
        if (user == null || order == null) {return;}
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String body = "Xin chao " + displayCustomerName(user) + ",\n\n"
                + "Don hang " + code + " da giao thanh cong.\n"
                + "Cam on ban da tin tuong va mua hang tai " + SHOP_NAME + ".";
        sendToUser(user, "Don hang giao thanh cong - " + code, body);
    }

    public void sendDeliveryFailedToUser(User user, Order order) {
        if (user == null || order == null) {return;}
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String body = "Xin chao " + displayCustomerName(user) + ",\n\n"
                + "Don hang " + code + " giao khong thanh cong.\n"
                + "Shop se kiem tra va xu ly cac buoc tiep theo neu can.";
        sendToUser(user, "Don hang giao khong thanh cong - " + code, body);
    }

    public void sendNewOrderToAdmin(Order order) {
        if (order == null) {return;}
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String body = "Co don hang moi " + code + ".\n"
                + "Tong tien: " + formatMoney(order.getTotalAmount()) + "\n"
                + "Vui long truy cap trang admin de kiem tra va xu ly.";
        sendToAdmins("Co don hang moi - " + code, body);
    }

    public void sendDeliveryFailedToAdmin(Order order) {
        if (order == null) {return;}
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String body = "Don hang " + code + " giao khong thanh cong.\n"
                + "Admin can kiem tra va xu ly hoan tien neu don da thanh toan online.";
        sendToAdmins("Co don giao that bai can xu ly - " + code, body);
    }

    public void sendRefundRequestedToUser(User user, Order order) {
        if (user == null || order == null) {return;}
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String body = "Xin chao " + displayCustomerName(user) + ",\n\n"
                + "Yeu cau hoan tien cho don hang " + code + " da duoc gui.\n"
                + "Shop se kiem tra va xu ly thu cong trong thoi gian som nhat.";
        sendToUser(user, "Da gui yeu cau hoan tien - " + code, body);
    }

    public void sendRefundResolvedToUser(RefundRequest refund, String status) {
        if (refund == null || status == null) {return;}
        String code = displayOrderNumber(refund.getOrderNumber(), refund.getOrderId());
        String subject;
        String body;
        if ("refunded".equals(status)) {
            subject = "Yeu cau hoan tien da duoc xu ly - " + code;
            body = "Shop da ghi nhan hoan tien cho don hang " + code + ".";
        } else if ("rejected".equals(status)) {
            subject = "Yeu cau hoan tien bi tu choi - " + code;
            body = "Yeu cau hoan tien cho don hang " + code + " da bi tu choi.";
        } else {
            return;
        }
        send(refund.getCustomerEmail(), subject, body);
    }

    public void sendRefundRequestedToAdmin(Order order) {
        if (order == null) {return;}
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String body = "Co yeu cau hoan tien moi cho don hang " + code + ".\n"
                + "Admin can kiem tra thong tin nhan tien va xu ly thu cong.";
        sendToAdmins("Co yeu cau hoan tien moi - " + code, body);
    }

    public void sendVariantStockAlertToAdmin(ProductVariant variant, Product product) {
        if (variant == null || !shouldSendStockAlertEmail(variant.getStockQuantity())) {return;}
        String productName = product != null && product.getName() != null
                ? product.getName()
                : "San pham #" + variant.getProductId();
        String variantName = variant.getVariantName() != null && !variant.getVariantName().trim().isEmpty()
                ? variant.getVariantName().trim()
                : "Bien the #" + variant.getId();
        int stock = variant.getStockQuantity();
        String subject = stock <= 0 ? "Bien the san pham het hang" : "Bien the san pham sap het hang";
        String body = productName + " - " + variantName + " hien con " + stock + " san pham.\n"
                + "Admin can kiem tra va nhap hang neu can.";
        sendToAdmins(subject + " - " + productName, body);
    }

    private boolean shouldSendStockAlertEmail(int stock) {
        return stock <= 0 || stock == 2 || stock == 10;
    }

    public void sendPasswordChangedAlert(User user) {
        if (user == null) {return;}
        String body = "Xin chao " + displayCustomerName(user) + ",\n\n"
                + "Mat khau tai khoan cua ban vua duoc thay doi thanh cong.\n"
                + "Neu khong phai ban thuc hien hanh dong nay, vui long lien he voi Admin ngay lap tuc de bao ve tai khoan.";
        sendToUser(user, "Canh bao bao mat: Mat khau cua ban da bi thay doi", body);
    }

    private void sendToUser(User user, String subject, String body) {
        if (user == null) {return;}
        send(user.getEmail(), subject, body);
    }

    private void sendToAdmins(String subject, String body) {
        List<String> adminEmails = DAOFactory.getInstance().getUserDAO().getActiveAdminEmails();
        for (String adminEmail : adminEmails) {
            send(adminEmail, subject, body);
        }
    }

    private void send(String toEmail, String subject, String body) {
        if (toEmail == null || toEmail.trim().isEmpty()) {return;}
        String recipient = toEmail.trim();
        CompletableFuture.runAsync(() -> {
            try {
                EmailService.sendEmail(recipient, subject, body);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    private String displayCustomerName(User user) {
        String fullName = ((user.getLastName() != null ? user.getLastName() : "") + " "
                + (user.getFirstName() != null ? user.getFirstName() : "")).trim();
        return fullName.isEmpty() ? user.getUsername() : fullName;
    }

    private String displayOrderNumber(String orderNumber, int orderId) {
        if (orderNumber != null && !orderNumber.trim().isEmpty()) {
            return "#" + orderNumber.trim();
        }
        return "#" + orderId;
    }

    private String formatMoney(double amount) {
        return MONEY_FORMAT.format(amount) + " VND";
    }
}
