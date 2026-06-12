package controller;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import dao.DAOFactory;
import dao.OrderDAO;
import model.order.Order;
import model.enums.OrderStatus;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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
        String status       = getStr(payload, "Status");
        String reason       = getStr(payload, "Reason");

        System.out.println("[GHN Webhook] OrderCode=" + ghnOrderCode + " | Status=" + status + " | Reason=" + reason);

        if (ghnOrderCode == null || ghnOrderCode.isEmpty()) {
            response.getWriter().write("{\"code\":200,\"message\":\"No OrderCode, skipped\"}");
            return;
        }
        Order order = orderDAO.getOrderByTrackingCode(ghnOrderCode);
        if (order == null) {
            System.err.println("[GHN Webhook] Không tìm thấy đơn có tracking_code=" + ghnOrderCode);
            response.getWriter().write("{\"code\":200,\"message\":\"Order not found, skipped\"}");
            return;
        }

        String result = processGHNStatus(order, status, reason);

        System.out.println("[GHN Webhook] Processed orderId=" + order.getId() + " result=" + result);
        response.getWriter().write("{\"code\":200,\"message\":\"" + result + "\"}");
    }

    private String processGHNStatus(Order order, String ghnStatus, String reason) {
        if (ghnStatus == null) return "no_status";
        String normalizedStatus = ghnStatus.trim().toLowerCase();

        switch (normalizedStatus) {

            case "delivered":
                if (order.getStatus() == OrderStatus.SHIPPING) {
                    boolean updated = orderDAO.completeOrderByGHN(order.getId());
                    return updated ? "completed_ok" : "complete_skipped_not_shipping";
                }
                return "already_processed";
            case "delivery_fail":
                System.out.println("[GHN Webhook] Giao thất bại lần này, đơn=" + order.getOrderNumber()
                        + ", reason=" + reason + " — GHN có thể thử lại");
                return "delivery_fail_logged";

            case "return":
            case "returned":
            case "cancel":
                if (order.getStatus() == OrderStatus.SHIPPING
                        || order.getStatus() == OrderStatus.PENDING) {
                    String failReason = buildReason(normalizedStatus, reason);
                    boolean updated = orderDAO.failOrderByGHN(order.getId(), failReason);
                    return updated ? "delivery_failed_ok" : "fail_skipped";
                }
                return "already_processed";
            default:
                System.out.println("[GHN Webhook] Trạng thái trung gian '" + ghnStatus
                        + "' cho đơn=" + order.getOrderNumber() + " — bỏ qua");
                return "intermediate_status_ignored";
        }
    }
    private String buildReason(String status, String reason) {
        StringBuilder sb = new StringBuilder();
        switch (status) {
            case "return":    sb.append("GHN đang hoàn hàng"); break;
            case "returned":  sb.append("GHN đã hoàn hàng về kho"); break;
            case "cancel":    sb.append("Vận đơn GHN bị hủy"); break;
            default:          sb.append("GHN: ").append(status);
        }
        if (reason != null && !reason.trim().isEmpty()) {
            sb.append(" — ").append(reason.trim());
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
