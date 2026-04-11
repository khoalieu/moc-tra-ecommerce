package controller.user;

import dao.UserDAO;
import model.user.User;
import model.enums.UserGender;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;

@WebServlet(name = "UpdateProfileInfoServlet", value = "/tai-khoan-cua-toi")
public class UpdateProfileInfoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }
        request.getRequestDispatcher("/user/thong-tin-tai-khoan-nguoi-dung.jsp").forward(request, response);
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        String firstName = request.getParameter("firstname");
        String lastName = request.getParameter("lastname");
        String phone = request.getParameter("phone");
        String dobStr = request.getParameter("dob");
        String genderRaw = request.getParameter("gender");

        LocalDate validatedDob = null;
        if (dobStr != null && !dobStr.isEmpty()) {
            try {
                validatedDob = LocalDate.parse(dobStr);

                if (validatedDob.isAfter(LocalDate.now())) {
                    session.setAttribute("msg", "Ngày sinh không được ở tương lai!");
                    session.setAttribute("msgType", "danger");
                    response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                    return;
                }
            } catch (java.time.format.DateTimeParseException e) {
                session.setAttribute("msg", "Định dạng ngày tháng không đúng (yyyy-MM-dd)!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                return;
            }
        }

        UserDAO dao = new UserDAO();
        String genderForDb = (genderRaw != null) ? genderRaw.toLowerCase() : "other";
        boolean isUpdated = false;

        try {
            isUpdated = dao.updateProfile(firstName, lastName, phone, dobStr, genderForDb, user.getId());
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (isUpdated) {
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setPhone(phone);

            if (dobStr == null || dobStr.trim().isEmpty()) {
                user.setDateOfBirth(null);
            } else if (validatedDob != null) {
                user.setDateOfBirth(validatedDob.atStartOfDay());
            }

            if (genderRaw != null && !genderRaw.isEmpty()) {
                try {
                    user.setGender(UserGender.valueOf(genderRaw.toUpperCase()));
                } catch (IllegalArgumentException e) {
                }
            }

            session.setAttribute("user", user);
            session.setAttribute("msg", "Cập nhật thông tin thành công!");
            session.setAttribute("msgType", "success");
        } else {
            session.setAttribute("msg", "Lỗi hệ thống! Vui lòng thử lại sau.");
            session.setAttribute("msgType", "danger");
        }

        response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
    }
}
