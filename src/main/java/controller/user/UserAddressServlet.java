package controller.user;

import dao.UserAddressDAO;
import model.user.User;
import model.user.UserAddress;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "UserAddressServlet", value = "/dia-chi-nguoi-dung")
public class UserAddressServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }
        UserAddressDAO dao = new UserAddressDAO();
        List<UserAddress> list = dao.getListAddress(user.getId());

        request.setAttribute("addressList", list);
        request.getRequestDispatcher("/user/dia-chi-nguoi-dung.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        UserAddressDAO dao = new UserAddressDAO();
        if ("add".equals(action)) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phoneNumber");
            String province = request.getParameter("province");
            String ward = request.getParameter("ward");
            String street = request.getParameter("addressLine");
            String label = request.getParameter("addressLabel");

            UserAddress addr = new UserAddress();
            addr.setUserId(user.getId());
            addr.setFullName(fullName);
            addr.setPhoneNumber(phone);
            addr.setProvince(province);
            addr.setWard(ward);
            addr.setStreetAddress(street);
            addr.setLabel(label);

            List<UserAddress> existing = dao.getListAddress(user.getId());
            if (existing.isEmpty()) {
                addr.setIsDefault(true);
            } else {
                addr.setIsDefault(false);
            }
            dao.addAddress(addr);
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteAddress(id, user.getId());

        } else if ("set_default".equals(action)) {
            int id = Integer.parseInt(request.getParameter("defaultAddressId"));
            boolean ok = dao.setDefaultAddress(id, user.getId());
            if(ok) {
                session.setAttribute("msg", "Xóa thành công!");
            }
        }
        response.sendRedirect(request.getContextPath() + "/dia-chi-nguoi-dung");
    }
}
