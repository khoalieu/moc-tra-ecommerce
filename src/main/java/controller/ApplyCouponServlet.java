package controller;

import com.google.gson.Gson;
import controller.utils.RedirectUtils;
import dao.CouponDAO;
import dao.DAOFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.cart.Cart;
import model.cart.CartItem;
import model.promotion.Coupon;
import model.user.User;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "ApplyCouponServlet", value = "/ap-dung-ma-giam-gia")
public class ApplyCouponServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        Map<String, Object> data = new HashMap<>();

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Cart cart = (Cart) session.getAttribute("cart");
        String[] selectedItemIds = (String[]) session.getAttribute("selectedItemIds");

        if (user == null) {
            data.put("success", false);
            data.put("status", "LOGIN_REQUIRED");
            data.put("loginUrl", RedirectUtils.toLoginWithRedirect(request, "/thanh-toan"));
            data.put("message", "Vui lòng đăng nhập để áp dụng mã giảm giá.");
            response.getWriter().write(gson.toJson(data));
            return;
        }

        if (cart == null || selectedItemIds == null || selectedItemIds.length == 0) {
            data.put("success", false);
            data.put("message", "Không tìm thấy sản phẩm thanh toán.");
            response.getWriter().write(gson.toJson(data));
            return;
        }

        double subtotal = calculateSelectedSubtotal(cart, selectedItemIds);

        String couponIdStr = request.getParameter("couponId");
        String couponCode = request.getParameter("couponCode");

        CouponDAO couponDAO = DAOFactory.getInstance().getCouponDAO();
        Coupon coupon = null;

        try {
            if (couponIdStr != null && !couponIdStr.trim().isEmpty()) {
                int couponId = Integer.parseInt(couponIdStr);
                coupon = couponDAO.getValidClaimedCouponForCheckout(user.getId(), couponId, subtotal);
            } else if (couponCode != null && !couponCode.trim().isEmpty()) {
                coupon = couponDAO.getValidCouponByCodeForCheckout(user.getId(), couponCode.trim(), subtotal);
            }

            if (coupon == null) {
                data.put("success", false);
                data.put("message", "Mã giảm giá không hợp lệ, đã dùng, hết lượt hoặc chưa đủ điều kiện đơn hàng.");
                response.getWriter().write(gson.toJson(data));
                return;
            }

            double discount = couponDAO.calculateDiscount(coupon, subtotal);

            data.put("success", true);
            data.put("message", "Áp dụng mã giảm giá thành công.");
            data.put("couponId", coupon.getId());
            data.put("couponCode", coupon.getCode());
            data.put("discountAmount", discount);
            data.put("discountType", coupon.getDiscountType());
            data.put("discountValue", coupon.getDiscountValue());

        } catch (Exception e) {
            e.printStackTrace();
            data.put("success", false);
            data.put("message", "Có lỗi xảy ra khi áp dụng mã giảm giá.");
        }

        response.getWriter().write(gson.toJson(data));
    }

    private double calculateSelectedSubtotal(Cart cart, String[] selectedItemIds) {
        double subtotal = 0;

        for (CartItem item : cart.getItems()) {
            for (String idStr : selectedItemIds) {
                try {
                    if (item.getVariantId() == Integer.parseInt(idStr)) {
                        subtotal += item.getTotalPrice();
                        break;
                    }
                } catch (Exception ignored) {
                }
            }
        }

        return subtotal;
    }
}
