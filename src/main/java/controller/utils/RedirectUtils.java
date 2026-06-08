package controller.utils;

import jakarta.servlet.http.HttpServletRequest;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

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

    public static String getCurrentPath(HttpServletRequest request) {
        if (request == null) {
            return "/";
        }

        String contextPath = request.getContextPath();
        String requestUri = request.getRequestURI();
        String path = requestUri;

        if (contextPath != null && !contextPath.isEmpty() && requestUri.startsWith(contextPath)) {
            path = requestUri.substring(contextPath.length());
        }

        if (path == null || path.isBlank()) {
            path = "/";
        }

        String query = request.getQueryString();
        if (query != null && !query.isBlank()) {
            path += "?" + query;
        }

        return path;
    }

    public static String toLoginWithRedirect(HttpServletRequest request, String redirect) {
        String safeRedirect = normalizeSafeRedirect(redirect);
        if (safeRedirect == null) {
            safeRedirect = "/";
        }

        return request.getContextPath()
                + "/login?redirect="
                + URLEncoder.encode(safeRedirect, StandardCharsets.UTF_8);
    }

    public static String getSafeRedirectOrDefault(HttpServletRequest request, String fallback) {
        String redirect = getSafeRedirect(request);
        return redirect != null ? redirect : normalizeSafeRedirect(fallback);
    }

    private static String normalizeSafeRedirect(String redirect) {
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
