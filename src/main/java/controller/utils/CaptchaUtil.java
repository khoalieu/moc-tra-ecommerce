
package controller.utils;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

public class CaptchaUtil {

    private static String SECRET_KEY;
    private static String SITE_KEY;
    private static final String VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify";

    static {
        loadCaptchaConfig();
    }

    private static void loadCaptchaConfig() {
        try (InputStream input = CaptchaUtil.class.getClassLoader().getResourceAsStream("captcha.properties")) {
            Properties prop = new Properties();

            if (input == null) {
                System.out.println("Ko tìm thấy file captcha.properties");
                return;
            }

            prop.load(input);
            SECRET_KEY = prop.getProperty("captcha.secret");
            SITE_KEY = prop.getProperty("captcha.site");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String getSiteKey() {
        return SITE_KEY;
    }

    public static boolean verify(String token) {
        if (token == null || token.isBlank()) {
            return false;
        }

        if (SECRET_KEY == null || SECRET_KEY.isBlank()) {
            System.out.println("lỗi chưa cấu hình captcha.secret");
            return false;
        }

        try {
            String postData = "secret=" + URLEncoder.encode(SECRET_KEY, StandardCharsets.UTF_8)
                    + "&response=" + URLEncoder.encode(token, StandardCharsets.UTF_8);

            URL url = new URL(VERIFY_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            try (OutputStream os = conn.getOutputStream()) {
                os.write(postData.getBytes(StandardCharsets.UTF_8));
            }

            StringBuilder result = new StringBuilder();
            try (BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    result.append(line);
                }
            }

            String json = result.toString();
            return json.contains("\"success\": true") || json.contains("\"success\":true");

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}