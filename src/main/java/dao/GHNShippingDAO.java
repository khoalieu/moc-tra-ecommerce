package dao;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import model.order.Order;
import model.user.UserAddress;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

public class GHNShippingDAO {

    private final String baseUrl;
    private final String token;
    private final int shopId;
    private final int fromDistrictId;
    private final String fromWardCode;
    private final int serviceTypeId;
    private final int defaultWeightGram;

    public GHNShippingDAO() {
        Properties props = new Properties();
        try (InputStream input = GHNShippingDAO.class.getClassLoader().getResourceAsStream("ghn.properties")) {
            if (input != null) props.load(input);
        } catch (IOException e) {
            e.printStackTrace();
        }
        // Biến môi trường Docker có ưu tiên cao hơn ghn.properties
        this.baseUrl           = getEnvOrProp("GHN_BASE_URL",          props, "ghn.base_url",           "https://dev-online-gateway.ghn.vn/shiip/public-api");
        this.token             = getEnvOrProp("GHN_TOKEN",             props, "ghn.token",              "");
        this.shopId            = parseInt(getEnvOrProp("GHN_SHOP_ID",  props, "ghn.shop_id",            "0"));
        this.fromDistrictId    = parseInt(getEnvOrProp("GHN_FROM_DISTRICT_ID", props, "ghn.from_district_id", "0"));
        this.fromWardCode      = getEnvOrProp("GHN_FROM_WARD_CODE",    props, "ghn.from_ward_code",     "");
        this.serviceTypeId     = parseInt(getEnvOrProp("GHN_SERVICE_TYPE_ID", props, "ghn.service_type_id", "2"));
        this.defaultWeightGram = parseInt(getEnvOrProp("GHN_DEFAULT_WEIGHT",  props, "ghn.default_weight_gram", "500"));
    }

    private static String getEnvOrProp(String envKey, Properties props, String propKey, String defaultVal) {
        String envVal = System.getenv(envKey);
        if (envVal != null && !envVal.isBlank()) return envVal.trim();
        return props.getProperty(propKey, defaultVal);
    }

    public long calculateShippingFee(int toDistrictId, String toWardCode, int weightGram) {
        try {
            JsonObject body = new JsonObject();
            body.addProperty("service_type_id", serviceTypeId);
            body.addProperty("from_district_id", fromDistrictId);
            body.addProperty("from_ward_code", fromWardCode);
            body.addProperty("to_district_id", toDistrictId);
            body.addProperty("to_ward_code", toWardCode);
            body.addProperty("weight", weightGram);
            body.addProperty("length", 20);
            body.addProperty("width", 15);
            body.addProperty("height", 10);

            JsonObject response = post("/v2/shipping-order/fee", body);
            if (response != null && response.has("data")) {
                return response.getAsJsonObject("data").get("total").getAsLong();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public long calculateFeeByProvinceName(String provinceName) {
        if (provinceName == null || provinceName.isEmpty()) return 30000;
        String lowerProvince = provinceName.toLowerCase();

        if (lowerProvince.contains("hà nội") || lowerProvince.contains("ha noi")) return 22000;
        if (lowerProvince.contains("hồ chí minh") || lowerProvince.contains("ho chi minh") || lowerProvince.contains("hcm")) return 22000;
        if (lowerProvince.contains("đà nẵng") || lowerProvince.contains("da nang")) return 30000;
        if (lowerProvince.contains("hải phòng") || lowerProvince.contains("hai phong")) return 25000;
        if (lowerProvince.contains("cần thơ") || lowerProvince.contains("can tho")) return 30000;

        if (lowerProvince.matches(".*(bắc giang|bắc kạn|bắc ninh|cao bằng|điện biên|hà giang|hà nam|hải dương|hưng yên|lai châu|lạng sơn|lào cai|nam định|ninh bình|phú thọ|quảng ninh|sơn la|thái bình|thái nguyên|tuyên quang|vĩnh phúc|yên bái).*"))
            return 25000;
        if (lowerProvince.matches(".*(bình định|bình thuận|đắk lắk|đắk nông|gia lai|hà tĩnh|khánh hòa|kon tum|ninh thuận|nghệ an|phú yên|quảng bình|quảng nam|quảng ngãi|quảng trị|thanh hóa|thừa thiên huế).*"))
            return 35000;
        if (lowerProvince.matches(".*(an giang|bà rịa|bạc liêu|bến tre|bình dương|bình phước|cà mau|đồng nai|đồng tháp|hậu giang|kiên giang|long an|sóc trăng|tây ninh|tiền giang|trà vinh|vĩnh long).*"))
            return 30000;

        return 35000;
    }
    public GHNCreateOrderResult createGHNOrder(Order order, UserAddress address,
                                               int toDistrictId, String toWardCode) {
        try {
            JsonObject body = new JsonObject();

            body.addProperty("to_name", address.getFullName());
            body.addProperty("to_phone", address.getPhoneNumber());
            body.addProperty("to_address", address.getStreetAddress());
            body.addProperty("to_ward_code", toWardCode);
            body.addProperty("to_district_id", toDistrictId);

            String paymentMethod = order.getPaymentMethod();
            boolean isCOD = (paymentMethod == null || "cod".equalsIgnoreCase(paymentMethod));
            body.addProperty("payment_type_id", isCOD ? 2 : 1);

            body.addProperty("service_type_id", serviceTypeId);
            body.addProperty("weight", defaultWeightGram);
            body.addProperty("length", 20);
            body.addProperty("width", 15);
            body.addProperty("height", 10);

            String note = order.getNotes();
            body.addProperty("note", note != null ? note : "");

            body.addProperty("required_note", "KHONGCHOXEMHANG");
            body.addProperty("cod_amount", isCOD ? (long) order.getTotalAmount() : 0L);
            body.addProperty("content", "Don hang " + order.getOrderNumber());
            JsonArray itemsArr = new JsonArray();
            JsonObject item = new JsonObject();
            item.addProperty("name", "San pham Moc Tra");
            item.addProperty("quantity", 1);
            item.addProperty("weight", defaultWeightGram);
            itemsArr.add(item);
            body.add("items", itemsArr);

            JsonObject response = post("/v2/shipping-order/create", body);
            if (response != null) {
                if (response.has("data") && response.get("data").isJsonObject()) {
                    JsonObject data = response.getAsJsonObject("data");
                    GHNCreateOrderResult result = new GHNCreateOrderResult();
                    result.orderCode = data.has("order_code") ? data.get("order_code").getAsString() : "";
                    result.expectedDeliveryTime = data.has("expected_delivery_time") && !data.get("expected_delivery_time").isJsonNull() ? data.get("expected_delivery_time").getAsString() : "";
                    result.totalFee = data.has("total_fee") && !data.get("total_fee").isJsonNull() ? data.get("total_fee").getAsLong() : 0;
                    return result;
                } else {
                    GHNCreateOrderResult result = new GHNCreateOrderResult();
                    String msg = "";
                    int ghnCode = response.has("code") ? response.get("code").getAsInt() : 0;
                    if (response.has("code_message_value") && !response.get("code_message_value").isJsonNull()
                            && !response.get("code_message_value").getAsString().isEmpty()) {
                        msg = response.get("code_message_value").getAsString();
                    } else if (response.has("message") && !response.get("message").isJsonNull()) {
                        msg = response.get("message").getAsString();
                    } else {
                        msg = "Lỗi không xác định từ GHN";
                    }
                    result.errorMessage = "[GHN " + ghnCode + "] " + msg;
                    System.err.println("[GHN] createGHNOrder FAILED: " + response);
                    return result;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            GHNCreateOrderResult result = new GHNCreateOrderResult();
            result.errorMessage = "Exception: " + e.getMessage();
            return result;
        }
        return null;
    }

    // =========================================================================
    // LẤY DANH SÁCH ĐỊA CHỈ GHN
    // =========================================================================

    public JsonElement getProvinces() {
        return get("/master-data/province");
    }

    public JsonElement getDistricts(int provinceId) {
        return get("/master-data/district?province_id=" + provinceId);
    }

    public JsonElement getWards(int districtId) {
        return get("/master-data/ward?district_id=" + districtId);
    }

    // =========================================================================
    // HTTP HELPERS
    // =========================================================================

    private JsonObject post(String path, JsonObject body) throws IOException {
        URL url = new URL(baseUrl + path);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Token", token);
        conn.setRequestProperty("ShopId", String.valueOf(shopId));
        conn.setDoOutput(true);
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(15000);

        byte[] input = body.toString().getBytes(StandardCharsets.UTF_8);
        try (OutputStream os = conn.getOutputStream()) {
            os.write(input);
        }

        int code = conn.getResponseCode();
        InputStream is = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
        if (is == null) return null;

        try (InputStreamReader reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {
            JsonElement parsed = JsonParser.parseReader(reader);
            System.out.println("[GHN] POST " + path + " -> code=" + code + ", response=" + parsed);
            return parsed.isJsonObject() ? parsed.getAsJsonObject() : null;
        }
    }

    private JsonElement get(String path) {
        try {
            URL url = new URL(baseUrl + path);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Token", token);
            conn.setRequestProperty("ShopId", String.valueOf(shopId));
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(15000);

            int code = conn.getResponseCode();
            InputStream is = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
            if (is == null) return null;

            try (InputStreamReader reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {
                return JsonParser.parseReader(reader);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private int parseInt(String s) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return 0; }
    }

    // =========================================================================
    // RESULT DTO
    // =========================================================================

    /**
     * Kết quả tạo vận đơn GHN thành công.
     */
    public static class GHNCreateOrderResult {
        public String orderCode;
        public String expectedDeliveryTime;
        public long totalFee;
        public String errorMessage;
    }
}
