package controller;

import com.google.gson.Gson;
import controller.utils.RedirectUtils;
import dao.CouponDAO;
import dao.DAOFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.user.User;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "ClaimCouponServlet", value = "/nhan-ma-giam-gia")
public class ClaimCouponServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        Map<String, Object> data = new HashMap<>();

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            String redirect = RedirectUtils.getSafeRedirectOrDefault(request, "/khuyen-mai");
            data.put("success", false);
            data.put("status", "LOGIN_REQUIRED");
            data.put("message", "Vui lòng đăng nhập để nhận mã giảm giá.");
            data.put("loginUrl", RedirectUtils.toLoginWithRedirect(request, redirect));
            response.getWriter().write(gson.toJson(data));
            return;
        }

        String couponIdStr = request.getParameter("couponId");

        if (couponIdStr == null || couponIdStr.trim().isEmpty()) {
            data.put("success", false);
            data.put("status", "INVALID");
            data.put("message", "Mã giảm giá không hợp lệ.");
            response.getWriter().write(gson.toJson(data));
            return;
        }

        try {
            int couponId = Integer.parseInt(couponIdStr);
            data.put("couponId", couponId);

            CouponDAO couponDAO = DAOFactory.getInstance().getCouponDAO();
            String result = couponDAO.claimCoupon(user.getId(), couponId);

            if ("SUCCESS".equals(result)) {
                data.put("success", true);
                data.put("status", "SUCCESS");
                data.put("message", "Nhận mã giảm giá thành công.");
            } else if ("ALREADY_CLAIMED".equals(result)) {
                data.put("success", false);
                data.put("status", "ALREADY_CLAIMED");
                data.put("message", "Bạn đã nhận mã này rồi.");
            } else if ("OUT_OF_STOCK".equals(result)) {
                data.put("success", false);
                data.put("status", "OUT_OF_STOCK");
                data.put("message", "Mã giảm giá này đã hết lượt nhận.");
            } else if ("NOT_FOUND".equals(result)) {
                data.put("success", false);
                data.put("status", "NOT_FOUND");
                data.put("message", "Mã giảm giá không tồn tại hoặc đã hết hạn.");
            } else {
                data.put("success", false);
                data.put("status", "ERROR");
                data.put("message", "Có lỗi xảy ra khi nhận mã. Vui lòng thử lại.");
            }

        } catch (NumberFormatException e) {
            data.put("success", false);
            data.put("status", "INVALID");
            data.put("message", "Mã giảm giá không hợp lệ.");
        } catch (Exception e) {
            e.printStackTrace();
            data.put("success", false);
            data.put("status", "ERROR");
            data.put("message", "Có lỗi xảy ra khi nhận mã. Vui lòng thử lại.");
        }

        response.getWriter().write(gson.toJson(data));
    }
}
