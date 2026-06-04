package controller;

import dao.CouponDAO;
import dao.DAOFactory;
import dao.PromotionDAO;
import model.product.Product;
import model.promotion.Coupon;
import model.promotion.Promotion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.user.User;

import java.io.IOException;
import java.util.*;

@WebServlet("/khuyen-mai")
public class PromotionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        PromotionDAO dao = DAOFactory.getInstance().getPromotionDAO();
        dao.syncPromotionPrices();

        CouponDAO couponDAO = DAOFactory.getInstance().getCouponDAO();

        User loggedInUser = (User) request.getSession().getAttribute("user");

        boolean isVipUser = loggedInUser != null && Boolean.TRUE.equals(loggedInUser.isVip());

        List<Promotion> allPromotions = dao.getPromotionsByType("ALL");
        List<Promotion> vipPromotions = new ArrayList<>();

        if (isVipUser) {
            vipPromotions = dao.getPromotionsByType("VIP");
        }

        Map<Promotion, List<Product>> allPromoMap = new LinkedHashMap<>();
        Map<Promotion, List<Product>> vipPromoMap = new LinkedHashMap<>();

        for (Promotion promo : allPromotions) {
            List<Product> products = dao.getProductsByPromotionId(promo.getId(), 8);
            if (products != null && !products.isEmpty()) {
                allPromoMap.put(promo, products);
            }
        }

        for (Promotion promo : vipPromotions) {
            List<Product> products = dao.getProductsByPromotionAndType(promo.getId(), "VIP", 8);
            if (products != null && !products.isEmpty()) {
                vipPromoMap.put(promo, products);
            }
        }

        List<Coupon> couponList = couponDAO.getActiveCouponsForPromotionPage();
        Set<Integer> claimedCouponIds = new HashSet<>();

        if (loggedInUser != null) {
            claimedCouponIds = couponDAO.getClaimedCouponIdsByUser(loggedInUser.getId());
        }

        request.setAttribute("activePromotions", allPromotions);
        request.setAttribute("promoMap", allPromoMap);
        request.setAttribute("vipPromoMap", vipPromoMap);
        request.setAttribute("isVipUser", isVipUser);

        request.setAttribute("couponList", couponList);
        request.setAttribute("claimedCouponIds", claimedCouponIds);

        request.getRequestDispatcher("/policy/khuyen-mai.jsp").forward(request, response);
    }
}