package controller;

import com.google.gson.JsonElement;
import dao.GHNShippingDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;


@WebServlet(urlPatterns = {
    "/api/ghn/fee",
    "/api/ghn/fee-by-name",
    "/api/ghn/provinces",
    "/api/ghn/districts",
    "/api/ghn/wards"
})
public class GHNShippingServlet extends HttpServlet {

    private GHNShippingDAO ghnDAO;

    @Override
    public void init() {
        ghnDAO = new GHNShippingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache");

        String path = request.getServletPath();

        try {
            switch (path) {
                case "/api/ghn/fee":
                    handleCalculateFee(request, response);
                    break;
                case "/api/ghn/fee-by-name":
                    handleFeeByName(request, response);
                    break;
                case "/api/ghn/provinces":
                    handleProvinces(response);
                    break;
                case "/api/ghn/districts":
                    handleDistricts(request, response);
                    break;
                case "/api/ghn/wards":
                    handleWards(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"error\":\"Endpoint không tồn tại\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Lỗi server\"}");
        }
    }

    private void handleCalculateFee(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String districtStr = request.getParameter("toDistrictId");
        String wardCode    = request.getParameter("toWardCode");
        String weightStr   = request.getParameter("weight");

        if (districtStr == null || wardCode == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Thiếu tham số toDistrictId hoặc toWardCode\"}");
            return;
        }

        int districtId = Integer.parseInt(districtStr.trim());
        int weight = (weightStr != null && !weightStr.isEmpty()) ? Integer.parseInt(weightStr.trim()) : 500;

        long fee = ghnDAO.calculateShippingFee(districtId, wardCode.trim(), weight);
        if (fee < 0) {
            response.getWriter().write("{\"fee\":30000,\"note\":\"Phí tạm tính\"}");
        } else {
            response.getWriter().write("{\"fee\":" + fee + "}");
        }
    }

    private void handleFeeByName(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String province = request.getParameter("province");
        long fee = ghnDAO.calculateFeeByProvinceName(province);
        response.getWriter().write("{\"fee\":" + fee + "}");
    }

    private void handleProvinces(HttpServletResponse response) throws IOException {
        JsonElement data = ghnDAO.getProvinces();
        if (data != null) {
            response.getWriter().write(data.toString());
        } else {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.getWriter().write("{\"error\":\"Không thể lấy dữ liệu từ GHN\"}");
        }
    }

    private void handleDistricts(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String provinceIdStr = request.getParameter("provinceId");
        if (provinceIdStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Thiếu tham số provinceId\"}");
            return;
        }
        int provinceId = Integer.parseInt(provinceIdStr.trim());
        JsonElement data = ghnDAO.getDistricts(provinceId);
        if (data != null) {
            response.getWriter().write(data.toString());
        } else {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.getWriter().write("{\"error\":\"Không thể lấy dữ liệu từ GHN\"}");
        }
    }

    private void handleWards(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String districtIdStr = request.getParameter("districtId");
        if (districtIdStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Thiếu tham số districtId\"}");
            return;
        }
        int districtId = Integer.parseInt(districtIdStr.trim());
        JsonElement data = ghnDAO.getWards(districtId);
        if (data != null) {
            response.getWriter().write(data.toString());
        } else {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.getWriter().write("{\"error\":\"Không thể lấy dữ liệu từ GHN\"}");
        }
    }
}
