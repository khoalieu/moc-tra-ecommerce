package controller.utils;

import java.io.IOException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.fluent.Form;
import org.apache.http.client.fluent.Request;
import com.google.gson.Gson;
import model.GooglePojo;
import java.util.Properties;
import java.io.InputStream;

public class GoogleUtils {
private static final java.util.Properties PROPS = loadProperties();
    private static final String GOOGLE_CLIENT_ID = PROPS.getProperty("GOOGLE_CLIENT_ID");
    private static final String GOOGLE_CLIENT_SECRET = PROPS.getProperty("GOOGLE_CLIENT_SECRET");

    public static final String GOOGLE_LINK_GET_TOKEN = "https://accounts.google.com/o/oauth2/token";
    public static final String GOOGLE_LINK_GET_USER_INFO = "https://www.googleapis.com/oauth2/v1/userinfo?access_token=";
    public static final String GOOGLE_GRANT_TYPE = "authorization_code";

    public static String getToken(final String code, String redirectUri) throws ClientProtocolException, IOException {
        String response = Request.Post(GOOGLE_LINK_GET_TOKEN)
                .bodyForm(Form.form().add("client_id", GOOGLE_CLIENT_ID)
                        .add("client_secret", GOOGLE_CLIENT_SECRET)
                        .add("redirect_uri", redirectUri).add("code", code)
                        .add("grant_type", GOOGLE_GRANT_TYPE).build())
                .execute().returnContent().asString();
        com.google.gson.JsonObject jobj = new Gson().fromJson(response, com.google.gson.JsonObject.class);
        String accessToken = jobj.get("access_token").getAsString();
        return accessToken;
    }

    public static GooglePojo getUserInfo(final String accessToken) throws ClientProtocolException, IOException {
        String link = GOOGLE_LINK_GET_USER_INFO + accessToken;
        String response = Request.Get(link).execute().returnContent().asString();
        GooglePojo googlePojo = new Gson().fromJson(response, GooglePojo.class);
        return googlePojo;
    }
    public static String getGoogleAuthUrl(String redirectUri) {
        StringBuilder url = new StringBuilder();
        url.append("https://accounts.google.com/o/oauth2/auth");
        url.append("?scope=email profile");
        url.append("&redirect_uri=").append(redirectUri);
        url.append("&response_type=code");
        url.append("&client_id=").append(GOOGLE_CLIENT_ID);
        url.append("&approval_prompt=force");
        return url.toString();
    }
    private static java.util.Properties loadProperties() {
        try (java.io.InputStream input = GoogleUtils.class.getClassLoader().getResourceAsStream("auth.properties")) {
            java.util.Properties prop = new java.util.Properties();
            if (input == null) {
                throw new RuntimeException("auth.properties not found in classpath");
            }
            prop.load(input);
            return prop;
        } catch (Exception e) {
            throw new RuntimeException("Failed to load auth.properties", e);
        }
    }
}