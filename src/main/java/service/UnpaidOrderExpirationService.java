package service;

import dao.DAOFactory;
import dao.OrderDAO;
import model.order.Order;

import java.util.List;

public class UnpaidOrderExpirationService {
    private static final int BATCH_SIZE = 50;
    private static final String AUTO_CANCEL_REASON = "Quá thời gian thanh toán 24 giờ";

    private final OrderDAO orderDAO;

    public UnpaidOrderExpirationService() {
        this.orderDAO = DAOFactory.getInstance().getOrderDAO();
    }

    public int cancelExpiredUnpaidOnlineOrders() {
        List<Order> orders = orderDAO.getAutoCancelableUnpaidOnlineOrders(BATCH_SIZE);
        int cancelled = 0;

        for (Order order : orders) {
            if (order != null && orderDAO.autoCancelUnpaidOnlineOrder(order.getId(), AUTO_CANCEL_REASON)) {
                cancelled++;
            }
        }

        if (cancelled > 0) {
            System.out.println("[UnpaidOrderExpiration] Auto-cancelled " + cancelled + " unpaid online orders.");
        }
        return cancelled;
    }
}
