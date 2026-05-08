package controller;

import dao.DAOFactory;
import dao.ShippingDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/api/get-shipping-fee")
public class GetShippingFeeServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String province = request.getParameter("province");

        ShippingDAO shippingDAO = DAOFactory.getInstance().getShippingDAO();
        double provinceFee = 30000;
        if (province != null && !province.isEmpty()) {
            provinceFee = shippingDAO.getFeeByProvince(province);
        }
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"provinceFee\": " + provinceFee + "}");
    }
}
