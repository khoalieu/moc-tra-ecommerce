package controller.utils;

import java.io.IOException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.fluent.Form;
import org.apache.http.client.fluent.Request;
import com.google.gson.Gson;
import model.GooglePojo;

public class GoogleUtils {
    public static final String GOOGLE_CLIENT_ID = "YOUR_CLIENT_ID_HERE"; //client id
    public static final String GOOGLE_CLIENT_SECRET = "YOUR_CLIENT_SECRET_HERE"; //client secret
    public static final String GOOGLE_REDIRECT_URI = "http://localhost:8080/the_tea_house_project_war_exploded/login-google";
    public static final String GOOGLE_LINK_GET_TOKEN = "https://accounts.google.com/o/oauth2/token";
    public static final String GOOGLE_LINK_GET_USER_INFO = "https://www.googleapis.com/oauth2/v1/userinfo?access_token=";
    public static final String GOOGLE_GRANT_TYPE = "authorization_code";

    public static String getToken(final String code) throws ClientProtocolException, IOException {
        String response = Request.Post(GOOGLE_LINK_GET_TOKEN)
                .bodyForm(Form.form().add("client_id", GOOGLE_CLIENT_ID)
                        .add("client_secret", GOOGLE_CLIENT_SECRET)
                        .add("redirect_uri", GOOGLE_REDIRECT_URI).add("code", code)
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
    public static String getGoogleAuthUrl() {
        StringBuilder url = new StringBuilder();
        url.append("https://accounts.google.com/o/oauth2/auth");
        url.append("?scope=email profile");
        url.append("&redirect_uri=").append(GOOGLE_REDIRECT_URI);
        url.append("&response_type=code");
        url.append("&client_id=").append(GOOGLE_CLIENT_ID);
        url.append("&approval_prompt=force");
        return url.toString();
    }
}