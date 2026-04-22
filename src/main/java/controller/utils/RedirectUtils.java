package controller.utils;

import jakarta.servlet.http.HttpServletRequest;

public class RedirectUtils {

    public static String getSafeRedirect(HttpServletRequest request) {
        String redirect = request.getParameter("redirect");

        if (redirect == null || redirect.trim().isEmpty()) {
            return null;
        }

        redirect = redirect.trim();

        if (!redirect.startsWith("/")) {
            return null;
        }

        if (redirect.startsWith("//") || redirect.contains("://")) {
            return null;
        }

        return redirect;
    }
}