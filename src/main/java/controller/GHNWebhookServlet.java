package controller;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import dao.DAOFactory;
import dao.OrderDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.enums.OrderStatus;
import model.order.Order;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.stream.Collectors;

@WebServlet(name = "GHNWebhookServlet", urlPatterns = {"/api/ghn/webhook"})
public class GHNWebhookServlet extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() {
        orderDAO = DAOFactory.getInstance().getOrderDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        String body;
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(request.getInputStream(), StandardCharsets.UTF_8))) {
            body = reader.lines().collect(Collectors.joining("\n"));
        }

        System.out.println("[GHN Webhook] Received: " + body);

        JsonObject payload;
        try {
            JsonElement parsed = JsonParser.parseString(body);
            if (!parsed.isJsonObject()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"code\":400,\"message\":\"Invalid JSON\"}");
                return;
            }
            payload = parsed.getAsJsonObject();
        } catch (Exception e) {
            System.err.println("[GHN Webhook] JSON parse error: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"code\":400,\"message\":\"JSON parse error\"}");
            return;
        }

        String ghnOrderCode = getStr(payload, "OrderCode");
        String status = getStr(payload, "Status");
        String reason = getStr(payload, "Reason");

        System.out.println("[GHN Webhook] OrderCode=" + ghnOrderCode + " | Status=" + status + " | Reason=" + reason);

        if (ghnOrderCode == null || ghnOrderCode.isEmpty()) {
            response.getWriter().write("{\"code\":200,\"message\":\"No OrderCode, skipped\"}");
            return;
        }

        Order order = orderDAO.getOrderByTrackingCode(ghnOrderCode);
        if (order == null) {
            System.err.println("[GHN Webhook] Order not found for tracking_code=" + ghnOrderCode);
            response.getWriter().write("{\"code\":200,\"message\":\"Order not found, skipped\"}");
            return;
        }

        orderDAO.saveShipmentEvent(order.getId(), ghnOrderCode, status, reason, body);
        String result = processGHNStatus(order, status, reason);

        System.out.println("[GHN Webhook] Processed orderId=" + order.getId() + " result=" + result);
        response.getWriter().write("{\"code\":200,\"message\":\"" + result + "\"}");
    }

    private String processGHNStatus(Order order, String ghnStatus, String reason) {
        if (ghnStatus == null || ghnStatus.trim().isEmpty()) {
            return "no_status";
        }

        String normalizedStatus = ghnStatus.trim().toLowerCase();
        switch (normalizedStatus) {
            case "ready_to_pick":
                return updateIntermediate(order, OrderStatus.PROCESSING, normalizedStatus, reason);

            case "picking":
            case "picked":
            case "storing":
            case "transporting":
            case "sorting":
            case "delivering":
            case "money_collect_picking":
            case "money_collect_delivering":
                return updateIntermediate(order, OrderStatus.SHIPPING, normalizedStatus, reason);

            case "delivery_fail":
                return updateIntermediate(order, OrderStatus.DELIVERY_ATTEMPT_FAILED, normalizedStatus, reason);

            case "waiting_to_return":
            case "return":
            case "return_transporting":
            case "return_sorting":
            case "returning":
            case "return_fail":
                return updateIntermediate(order, OrderStatus.RETURNING, normalizedStatus, reason);

            case "delivered":
                if (canMoveFromGHN(order)) {
                    boolean updated = orderDAO.completeOrderByGHN(order.getId());
                    return updated ? "completed_ok" : "complete_skipped";
                }
                return "already_processed";

            case "returned":
            case "cancel":
            case "lost":
            case "damage":
            case "exception":
                if (canMoveFromGHN(order)) {
                    boolean updated = orderDAO.failOrderByGHN(order.getId(), buildReason(normalizedStatus, reason));
                    return updated ? "delivery_failed_ok" : "fail_skipped";
                }
                return "already_processed";

            default:
                System.out.println("[GHN Webhook] Ignored GHN status '" + ghnStatus
                        + "' for order=" + order.getOrderNumber());
                return "intermediate_status_ignored";
        }
    }

    private boolean canMoveFromGHN(Order order) {
        OrderStatus status = order.getStatus();
        return status == OrderStatus.PENDING
                || status == OrderStatus.PROCESSING
                || status == OrderStatus.SHIPPING
                || status == OrderStatus.DELIVERY_ATTEMPT_FAILED
                || status == OrderStatus.RETURNING;
    }

    private String updateIntermediate(Order order, OrderStatus nextStatus, String ghnStatus, String reason) {
        if (!canMoveFromGHN(order)) {
            return "already_final";
        }

        boolean updated = orderDAO.updateGHNOrderStatus(order.getId(), nextStatus, buildReason(ghnStatus, reason));
        return updated ? "status_" + nextStatus.name().toLowerCase() : "status_skipped";
    }

    private String buildReason(String status, String reason) {
        StringBuilder sb = new StringBuilder();
        switch (status) {
            case "ready_to_pick": sb.append("GHN: Chờ lấy hàng"); break;
            case "picking": sb.append("GHN: Đang lấy hàng"); break;
            case "picked": sb.append("GHN: Đã lấy hàng"); break;
            case "storing": sb.append("GHN: Hàng đang lưu kho"); break;
            case "transporting": sb.append("GHN: Đang trung chuyển"); break;
            case "sorting": sb.append("GHN: Đang phân loại"); break;
            case "delivering": sb.append("GHN: Đang giao hàng"); break;
            case "delivery_fail": sb.append("GHN: Giao hàng chưa thành công, có thể giao lại"); break;
            case "waiting_to_return": sb.append("GHN: Chờ hoàn hàng"); break;
            case "return": sb.append("GHN: Đang hoàn hàng"); break;
            case "return_transporting": sb.append("GHN: Đang trung chuyển hoàn hàng"); break;
            case "return_sorting": sb.append("GHN: Đang phân loại hoàn hàng"); break;
            case "returning": sb.append("GHN: Đang hoàn hàng về shop"); break;
            case "return_fail": sb.append("GHN: Hoàn hàng chưa thành công"); break;
            case "returned": sb.append("GHN: Đã hoàn hàng về shop"); break;
            case "cancel": sb.append("GHN: Vận đơn bị hủy"); break;
            case "lost": sb.append("GHN: Hàng bị thất lạc"); break;
            case "damage": sb.append("GHN: Hàng bị hư hỏng"); break;
            case "exception": sb.append("GHN: Đơn hàng phát sinh ngoại lệ"); break;
            default: sb.append("GHN: ").append(status);
        }
        if (reason != null && !reason.trim().isEmpty()) {
            sb.append(" - ").append(reason.trim());
        }
        return sb.toString();
    }

    private String getStr(JsonObject obj, String key) {
        try {
            JsonElement el = obj.get(key);
            return (el != null && !el.isJsonNull()) ? el.getAsString() : null;
        } catch (Exception e) {
            return null;
        }
    }
}
