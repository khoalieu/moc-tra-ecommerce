package controller.user;
import dao.CouponDAO;
import dao.DAOFactory;
import dao.VipVoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.promotion.Coupon;
import model.promotion.VipVoucher;
import model.user.User;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "MyVouchersServlet", value = "/ma-uu-dai-cua-toi")
public class MyVouchersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        CouponDAO couponDAO = DAOFactory.getInstance().getCouponDAO();
        List<Coupon> userCoupons = couponDAO.getAvailableCouponsForUser(user.getId());

        List<VipVoucher> vipVouchers = new ArrayList<>();

        if (Boolean.TRUE.equals(user.getIsVip())) {
            VipVoucherDAO vipVoucherDAO = DAOFactory.getInstance().getVipVoucherDAO();
            vipVouchers = vipVoucherDAO.getActiveVouchersForUser(user.getId());
        }

        request.setAttribute("userCoupons", userCoupons);
        request.setAttribute("vipVouchers", vipVouchers);
        request.setAttribute("couponCount", userCoupons != null ? userCoupons.size() : 0);
        request.setAttribute("vipVoucherCount", vipVouchers != null ? vipVouchers.size() : 0);

        request.getRequestDispatcher("/user/my-vouchers.jsp").forward(request, response);
    }
}
