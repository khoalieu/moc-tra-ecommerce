package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RouterServlet", urlPatterns = {
        "/ve-chung-toi",
        "/tra-thao-moc",
        "/tra-sua-nguyen-lieu",
        "/chinh-sach-ban-hang",
        "/chinh-sach-thanh-toan",
        "/chinh-sach-bao-hanh",
        "/dieu-khoan-dich-vu"
})
public class RouterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        String targetPage = "";
        String pageTitle = "";

        switch (path) {
            case "/ve-chung-toi":
                targetPage = "ve-chung-toi.jsp";
                pageTitle = "Về Chúng Tôi";
                break;
            case "/tra-thao-moc":
                targetPage = "tra-thao-moc.jsp";
                pageTitle = "Trà Thảo Mộc";
                break;
            case "/tra-sua-nguyen-lieu":
                targetPage = "tra-sua-nguyen-lieu.jsp";
                pageTitle = "Nguyên Liệu Trà Sữa";
                break;
            case "/chinh-sach-ban-hang":
                targetPage = "chinh-sach-ban-hang.jsp";
                pageTitle = "Chính Sách Bán Hàng";
                break;

            case "/chinh-sach-thanh-toan":
                targetPage = "chinh-sach-thanh-toan.jsp";
                pageTitle = "Chính Sách Thanh Toán";
                break;

            case "/chinh-sach-bao-hanh":
                targetPage = "chinh-sach-bao-hanh.jsp";
                pageTitle = "Chính Sách Bảo Hành";
                break;

            case "/dieu-khoan-dich-vu":
                targetPage = "dieu-khoan-dich-vu.jsp";
                pageTitle = "Điều Khoản Dịch Vụ";
                break;

            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
        }
        request.setAttribute("pageTitle", pageTitle);
        request.getRequestDispatcher(targetPage).forward(request, response);
    }
}