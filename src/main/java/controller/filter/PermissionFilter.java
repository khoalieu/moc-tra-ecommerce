package controller.filter;

import model.user.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebFilter(filterName = "PermissionFilter", urlPatterns = {"/admin/*", "/editor/*"})
public class PermissionFilter implements Filter {

    private static final Map<String, String> PERMISSION_MAP = new HashMap<>();

    static {
        PERMISSION_MAP.put("/admin/dashboard",           "dashboard.view");
        PERMISSION_MAP.put("/admin/products",            "product.view");
        PERMISSION_MAP.put("/admin/product-add",         "product.create");
        PERMISSION_MAP.put("/admin/product-edit",        "product.edit");
        PERMISSION_MAP.put("/admin/product-list",        "product.view");
        PERMISSION_MAP.put("/admin/product-status",      "product.status");
        PERMISSION_MAP.put("/admin/product-variant",     "product.edit");
        PERMISSION_MAP.put("/admin/product-import",      "product.import");
        PERMISSION_MAP.put("/admin/product-template",    "product.import");
        PERMISSION_MAP.put("/admin/product-quick-discount", "product.edit");
        
        PERMISSION_MAP.put("/admin/product/add",         "product.create");
        PERMISSION_MAP.put("/admin/product/edit",        "product.edit");
        PERMISSION_MAP.put("/admin/product/delete",      "product.create");
        PERMISSION_MAP.put("/admin/product/status",      "product.status");
        PERMISSION_MAP.put("/admin/product/quick-discount", "product.edit");
        PERMISSION_MAP.put("/admin/product/variant/process", "product.edit");
        PERMISSION_MAP.put("/admin/products/import",     "product.import");
        PERMISSION_MAP.put("/admin/products/template",   "product.import");
        
        PERMISSION_MAP.put("/admin/inventory",           "product.view");
        PERMISSION_MAP.put("/admin/products/inventory-import", "product.import");
        PERMISSION_MAP.put("/admin/products/inventory-template", "product.import");

        PERMISSION_MAP.put("/admin/orders",              "order.view");
        PERMISSION_MAP.put("/admin/order/detail",        "order.view");
        PERMISSION_MAP.put("/admin/order/update",        "order.edit");
        PERMISSION_MAP.put("/admin/order-edit-invoice",  "order.edit");
        PERMISSION_MAP.put("/admin/order-ghn",           "order.shipping");
        PERMISSION_MAP.put("/admin/order/ghn-create",    "order.shipping");
        PERMISSION_MAP.put("/admin/refunds",             "order.refund");

        PERMISSION_MAP.put("/admin/customers",           "customer.view");
        PERMISSION_MAP.put("/admin/customer/detail",     "customer.view");
        PERMISSION_MAP.put("/admin/customer/edit",       "customer.edit");

        PERMISSION_MAP.put("/admin/blog/add",            "blog.create");
        PERMISSION_MAP.put("/admin/blog/edit",           "blog.edit_own");
        PERMISSION_MAP.put("/admin/blog/delete",         "blog.delete_own");
        PERMISSION_MAP.put("/admin/blog/status-update",  "blog.publish");
        PERMISSION_MAP.put("/admin/blog/change-status",  "blog.publish");
        PERMISSION_MAP.put("/admin/blog/detail",         "blog.view");
        PERMISSION_MAP.put("/admin/blog-categories",     "blog.manage_category");
        PERMISSION_MAP.put("/admin/blog",                "blog.view");
        
        PERMISSION_MAP.put("/admin/categories",          "category.manage");
        PERMISSION_MAP.put("/admin/banner",              "banner.manage");
        PERMISSION_MAP.put("/admin/promotions",          "promotion.manage");
        PERMISSION_MAP.put("/admin/vouchers",            "promotion.manage");
        PERMISSION_MAP.put("/admin/promotion/add-products", "promotion.manage");
        
        PERMISSION_MAP.put("/admin/roles",               "role.manage");
        PERMISSION_MAP.put("/admin/system-log",          "system.logs");
        PERMISSION_MAP.put("/admin/system-logs",         "system.logs");
        
        PERMISSION_MAP.put("/admin/contacts",            "contact.manage");
        PERMISSION_MAP.put("/admin/notifications",       "dashboard.view");

        PERMISSION_MAP.put("/editor/dashboard",          "dashboard.view");
        PERMISSION_MAP.put("/editor/blog/add",           "blog.create");
        PERMISSION_MAP.put("/editor/blog/edit",          "blog.edit_own");
        PERMISSION_MAP.put("/editor/blog/delete",        "blog.delete_own");
        PERMISSION_MAP.put("/editor/blog/status-update", "blog.publish");
        PERMISSION_MAP.put("/editor/blog/change-status", "blog.publish");
        PERMISSION_MAP.put("/editor/blog/detail",        "blog.view");
        PERMISSION_MAP.put("/editor/blog",               "blog.view");
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void destroy() {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.startsWith(contextPath) ? uri.substring(contextPath.length()) : uri;

        String requiredPermission = resolveRequiredPermission(path);

        if (requiredPermission != null && !user.hasPermission(requiredPermission)) {
            res.sendRedirect(req.getContextPath() + "/errors/403.jsp");
            return;
        }

        chain.doFilter(request, response);
    }

    private String resolveRequiredPermission(String path) {
        if (PERMISSION_MAP.containsKey(path)) {
            return PERMISSION_MAP.get(path);
        }
        java.util.List<String> keys = new java.util.ArrayList<>(PERMISSION_MAP.keySet());
        keys.sort((k1, k2) -> Integer.compare(k2.length(), k1.length()));
        for (String key : keys) {
            if (path.startsWith(key)) {
                return PERMISSION_MAP.get(key);
            }
        }
        return null;
    }
}
