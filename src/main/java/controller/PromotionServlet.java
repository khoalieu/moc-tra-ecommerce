package backend.controller;

import dao.PromotionDAO;
import model.Product;
import model.Promotion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/khuyen-mai")
public class PromotionServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PromotionDAO dao = new PromotionDAO();
        List<Promotion> activePromotions = dao.getActivePromotions();
        Map<Promotion, List<Product>> promoMap = new LinkedHashMap<>();

        for (Promotion promo : activePromotions) {
            List<Product> products = dao.getProductsByPromotionId(promo.getId(),8);

            if (!products.isEmpty()) {
                promoMap.put(promo, products);
            }
        }

        request.setAttribute("activePromotions", activePromotions);
        request.setAttribute("promoMap", promoMap);
        request.getRequestDispatcher("/khuyen-mai.jsp").forward(request, response);
    }
}