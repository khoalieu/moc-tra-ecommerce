package controller.utils;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import model.order.Order;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Properties;
import java.util.TreeMap;

public class PaymentUtils {
    private static final Properties props = new Properties();
    private static final Gson gson = new Gson();

    static {
        try (InputStream input = PaymentUtils.class.getClassLoader().getResourceAsStream("payment.properties")) {
            if (input == null) {
                throw new RuntimeException("Không tìm thấy file payment.properties trong resources");
            }
            props.load(input);
        } catch (Exception e) {
            throw new RuntimeException("Lỗi load payment.properties", e);
        }
    }

    private static String getConfig(String key) {
        return props.getProperty(key);
    }

    public static PaymentResult createPayosPayment(Order order) {
        long providerOrderCode = generatePayosOrderCode(order.getId());
        return createPayosPayment(order, providerOrderCode);
    }

    public static PaymentResult createPayosPayment(Order order, long providerOrderCode) {
        try {
            String endpoint = getConfig("payos.endpoint");
            String clientId = getConfig("payos.clientId");
            String apiKey = getConfig("payos.apiKey");
            String checksumKey = getConfig("payos.checksumKey");

            String returnUrl = getConfig("payos.returnUrl") + "?orderId=" + order.getId();
            String cancelUrl = getConfig("payos.cancelUrl") + "?orderId=" + order.getId();

            long amount = Math.round(order.getTotalAmount());
            long orderCode = providerOrderCode;
            String description = "MOCTRA" + order.getId();

            String signatureData = "amount=" + amount +
                    "&cancelUrl=" + cancelUrl +
                    "&description=" + description +
                    "&orderCode=" + orderCode +
                    "&returnUrl=" + returnUrl;

            String signature = hmacSha256(signatureData, checksumKey);

            Map<String, Object> body = new LinkedHashMap<>();
            body.put("orderCode", orderCode);
            body.put("amount", amount);
            body.put("description", description);
            body.put("returnUrl", returnUrl);
            body.put("cancelUrl", cancelUrl);
            body.put("signature", signature);

            String jsonBody = gson.toJson(body);

            HttpClient client = HttpClient.newBuilder()
                    .version(HttpClient.Version.HTTP_1_1)
                    .connectTimeout(java.time.Duration.ofSeconds(30))
                    .build();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .version(HttpClient.Version.HTTP_1_1)
                    .timeout(java.time.Duration.ofSeconds(30))
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .header("User-Agent", "Mozilla/5.0")
                    .header("x-client-id", clientId)
                    .header("x-api-key", apiKey)
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = client.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );

            JsonObject json = gson.fromJson(response.body(), JsonObject.class);
            String code = getJsonString(json, "code");

            if (!"00".equals(code)) {
                throw new RuntimeException("payOS tạo thanh toán thất bại: " + response.body());
            }

            JsonObject data = json.getAsJsonObject("data");

            String checkoutUrl = getJsonString(data, "checkoutUrl");
            String qrCode = getJsonString(data, "qrCode");

            String qrImage;
            if (qrCode != null && !qrCode.isEmpty()) {
                qrImage = createBase64Qr(qrCode, 320, 320);
            } else {
                qrImage = createBase64Qr(checkoutUrl, 320, 320);
            }

            PaymentResult result = new PaymentResult();
            result.setProvider("payos");
            result.setRequestId("PAYOS_" + order.getId() + "_" + System.currentTimeMillis());
            result.setProviderOrderId(String.valueOf(orderCode));
            result.setQrCodeUrl(qrImage);
            result.setPayUrl(checkoutUrl);
            result.setDeeplink(null);
            result.setRawResponse(response.body());

            return result;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi tạo thanh toán payOS: " + e.getMessage(), e);
        }
    }

    private static long generatePayosOrderCode(int orderId) {
        String suffix = String.valueOf(System.currentTimeMillis()).substring(5);
        return Long.parseLong(orderId + suffix);
    }

    public static boolean verifyPayosWebhook(JsonObject webhookJson) {
        try {
            String checksumKey = getConfig("payos.checksumKey");

            if (webhookJson == null || !webhookJson.has("data") || !webhookJson.has("signature")) {
                return false;
            }

            JsonObject data = webhookJson.getAsJsonObject("data");
            String receivedSignature = getJsonString(webhookJson, "signature");

            String signatureData = buildPayosSignatureData(data);
            String expectedSignature = hmacSha256(signatureData, checksumKey);

            return expectedSignature.equals(receivedSignature);

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static String confirmPayosWebhook() {
        try {
            String endpoint = getConfig("payos.confirmWebhookEndpoint");
            String clientId = getConfig("payos.clientId");
            String apiKey = getConfig("payos.apiKey");
            String webhookUrl = getConfig("payos.webhookUrl");

            Map<String, Object> body = new LinkedHashMap<>();
            body.put("webhookUrl", webhookUrl);

            String jsonBody = gson.toJson(body);

            HttpClient client = HttpClient.newBuilder()
                    .version(HttpClient.Version.HTTP_1_1)
                    .connectTimeout(java.time.Duration.ofSeconds(30))
                    .build();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .version(HttpClient.Version.HTTP_1_1)
                    .timeout(java.time.Duration.ofSeconds(30))
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .header("User-Agent", "Mozilla/5.0")
                    .header("x-client-id", clientId)
                    .header("x-api-key", apiKey)
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = client.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );
            return response.body();

        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR: " + e.getMessage();
        }
    }

    private static String buildPayosSignatureData(JsonObject data) {
        TreeMap<String, String> sorted = new TreeMap<>();

        for (Map.Entry<String, JsonElement> entry : data.entrySet()) {
            String key = entry.getKey();
            JsonElement value = entry.getValue();

            if (value == null || value.isJsonNull()) {
                sorted.put(key, "");
            } else if (value.isJsonPrimitive()) {
                sorted.put(key, value.getAsString());
            } else {
                sorted.put(key, gson.toJson(value));
            }
        }

        StringBuilder sb = new StringBuilder();

        for (Map.Entry<String, String> entry : sorted.entrySet()) {
            if (sb.length() > 0) sb.append("&");
            sb.append(entry.getKey()).append("=").append(entry.getValue());
        }

        return sb.toString();
    }

    private static String hmacSha256(String data, String secretKey) {
        try {
            Mac hmac = Mac.getInstance("HmacSHA256");
            SecretKeySpec keySpec = new SecretKeySpec(secretKey.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            hmac.init(keySpec);

            byte[] bytes = hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder result = new StringBuilder();

            for (byte b : bytes) {
                result.append(String.format("%02x", b));
            }
            return result.toString();
        } catch (Exception e) {
            throw new RuntimeException("Lỗi tạo HMAC SHA256", e);
        }
    }

    private static String createBase64Qr(String content, int width, int height) {
        try {
            QRCodeWriter writer = new QRCodeWriter();
            BitMatrix matrix = writer.encode(content, BarcodeFormat.QR_CODE, width, height);

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(matrix, "PNG", outputStream);

            String base64 = Base64.getEncoder().encodeToString(outputStream.toByteArray());
            return "data:image/png;base64," + base64;

        } catch (Exception e) {
            throw new RuntimeException("Lỗi tạo QR Code", e);
        }
    }

    private static String getJsonString(JsonObject json, String key) {
        if (json == null || !json.has(key) || json.get(key).isJsonNull()) {
            return "";
        }
        return json.get(key).getAsString();
    }

    public static PaymentResult createMomoPayment(Order order) {
        try {
            String endpoint = getConfig("momo.endpoint");
            String partnerCode = getConfig("momo.partnerCode");
            String accessKey = getConfig("momo.accessKey");
            String secretKey = getConfig("momo.secretKey");
            String redirectUrl = getConfig("momo.redirectUrl");
            String ipnUrl = getConfig("momo.ipnUrl");

            String requestType = "captureWallet";
            String orderId = order.getOrderNumber();
            String requestId = orderId + "_" + System.currentTimeMillis();
            String orderInfo = "Thanh toan don hang " + order.getOrderNumber();
            String extraData = "";
            long amount = Math.round(order.getTotalAmount());

            String rawSignature = "accessKey=" + accessKey + "&amount=" + amount + "&extraData=" + extraData +
                            "&ipnUrl=" + ipnUrl + "&orderId=" + orderId + "&orderInfo=" + orderInfo +
                            "&partnerCode=" + partnerCode + "&redirectUrl=" + redirectUrl + "&requestId=" + requestId +
                            "&requestType=" + requestType;

            String signature = hmacSha256(rawSignature, secretKey);

            Map<String, Object> body = new LinkedHashMap<>();
            body.put("partnerCode", partnerCode);
            body.put("requestId", requestId);
            body.put("amount", amount);
            body.put("orderId", orderId);
            body.put("orderInfo", orderInfo);
            body.put("redirectUrl", redirectUrl);
            body.put("ipnUrl", ipnUrl);
            body.put("requestType", requestType);
            body.put("extraData", extraData);
            body.put("lang", "vi");
            body.put("signature", signature);

            String jsonBody = gson.toJson(body);

            HttpClient client = HttpClient.newBuilder()
                    .version(HttpClient.Version.HTTP_1_1)
                    .connectTimeout(java.time.Duration.ofSeconds(30))
                    .build();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .version(HttpClient.Version.HTTP_1_1)
                    .timeout(java.time.Duration.ofSeconds(30))
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .header("User-Agent", "Mozilla/5.0")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = client.send(
                    request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8)
            );

            JsonObject json = gson.fromJson(response.body(), JsonObject.class);

            int resultCode = json.has("resultCode") ? json.get("resultCode").getAsInt() : -1;

            if (resultCode != 0) {
                throw new RuntimeException("MoMo tạo thanh toán thất bại: " + response.body());
            }

            String payUrl = getJsonString(json, "payUrl");
            String deeplink = getJsonString(json, "deeplink");
            String qrCodeUrl = getJsonString(json, "qrCodeUrl");

            if ((qrCodeUrl == null || qrCodeUrl.isEmpty()) && payUrl != null && !payUrl.isEmpty()) {
                qrCodeUrl = createBase64Qr(payUrl, 320, 320);
            }

            PaymentResult result = new PaymentResult();
            result.setProvider("momo");
            result.setRequestId(requestId);
            result.setProviderOrderId(orderId);
            result.setQrCodeUrl(qrCodeUrl);
            result.setPayUrl(payUrl);
            result.setDeeplink(deeplink);
            result.setRawResponse(response.body());

            return result;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi tạo thanh toán MoMo: " + e.getMessage(), e);
        }
    }
    public static boolean verifyMomoIpnSignature(JsonObject json) {
        try {
            String accessKey = getConfig("momo.accessKey");
            String secretKey = getConfig("momo.secretKey");

            String rawSignature =
                    "accessKey=" + accessKey +
                            "&amount=" + getJsonString(json, "amount") +
                            "&extraData=" + getJsonString(json, "extraData") +
                            "&message=" + getJsonString(json, "message") +
                            "&orderId=" + getJsonString(json, "orderId") +
                            "&orderInfo=" + getJsonString(json, "orderInfo") +
                            "&orderType=" + getJsonString(json, "orderType") +
                            "&partnerCode=" + getJsonString(json, "partnerCode") +
                            "&payType=" + getJsonString(json, "payType") +
                            "&requestId=" + getJsonString(json, "requestId") +
                            "&responseTime=" + getJsonString(json, "responseTime") +
                            "&resultCode=" + getJsonString(json, "resultCode") +
                            "&transId=" + getJsonString(json, "transId");

            String expectedSignature = hmacSha256(rawSignature, secretKey);
            String receivedSignature = getJsonString(json, "signature");

            return expectedSignature.equals(receivedSignature);

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}