package controller.user;

import dao.DAOFactory;
import dao.UserAddressDAO;
import dao.UserDAO;
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
        UserAddressDAO dao = DAOFactory.getInstance().getUserAddressDAO();
        List<UserAddress> list = dao.getListAddress(user.getId());

        String action = request.getParameter("action");
        if ("view_edit".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            UserAddress address = dao.getAddressById(id);
            request.setAttribute("addressToEdit", address);
            request.getRequestDispatcher("/user/edit-user-address.jsp").forward(request, response);
            return;
        }

        request.setAttribute("addressList", list);
        request.getRequestDispatcher("/user/dia-chi-nguoi-dung.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        UserDAO userDAO = DAOFactory.getInstance().getUserDAO();

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        UserAddressDAO dao = DAOFactory.getInstance().getUserAddressDAO();
        if ("add".equals(action)) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phoneNumber");
            String province = request.getParameter("province");
            String district = request.getParameter("district");
            String ward = request.getParameter("ward");
            String street = request.getParameter("addressLine");
            String label = request.getParameter("addressLabel");
            String districtIdStr = request.getParameter("districtId");
            String wardCode = request.getParameter("wardCode");

            if (fullName == null || fullName.trim().isEmpty() ||
                    province == null || province.trim().isEmpty() ||
                    district == null || district.trim().isEmpty() ||
                    ward == null || ward.trim().isEmpty() ||
                    street == null || street.trim().isEmpty() ||
                    phone == null || !userDAO.isValidCarrier(phone.trim())) {

                session.setAttribute("msg", "Lỗi: Thông tin không được để trống và Số điện thoại phải đúng định dạng VN!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/dia-chi-nguoi-dung");
                return;
            }

            UserAddress addr = new UserAddress();
            addr.setUserId(user.getId());
            addr.setFullName(fullName);
            addr.setPhoneNumber(phone);
            addr.setProvince(province);
            addr.setDistrict(district);
            addr.setWard(ward);
            addr.setStreetAddress(street);
            addr.setLabel(label);
            if (districtIdStr != null && !districtIdStr.isEmpty()) {
                try { addr.setDistrictId(Integer.parseInt(districtIdStr)); } catch (NumberFormatException ignored) {}
            }
            if (wardCode != null && !wardCode.isEmpty()) addr.setWardCode(wardCode);

            List<UserAddress> existing = dao.getListAddress(user.getId());
            if (existing.isEmpty()) {
                addr.setDefault(true);
            } else {
                addr.setDefault(false);
            }
            dao.addAddress(addr);
            session.setAttribute("msg", "Thêm địa chỉ mới thành công!");
            session.setAttribute("msgType", "success");
        }else if ("edit".equals(action)) {
            try {
                int addressId = Integer.parseInt(request.getParameter("addressId"));
                UserAddress oldAddr = dao.getAddressById(addressId);

                String fullName = request.getParameter("fullName");
                String phone = request.getParameter("phoneNumber");
                String province = request.getParameter("province");
                String district = request.getParameter("district");
                String ward = request.getParameter("ward");
                String street = request.getParameter("addressLine");
                String label = request.getParameter("addressLabel");
                String districtIdStr = request.getParameter("districtId");
                String wardCode = request.getParameter("wardCode");

                if (fullName == null || fullName.trim().isEmpty()) fullName = oldAddr.getFullName();
                if (phone == null || phone.trim().isEmpty()) phone = oldAddr.getPhoneNumber();
                if (province == null || province.trim().isEmpty()) province = oldAddr.getProvince();
                if (district == null || district.trim().isEmpty()) district = oldAddr.getDistrict();
                if (ward == null || ward.trim().isEmpty()) ward = oldAddr.getWard();
                if (street == null || street.trim().isEmpty()) street = oldAddr.getStreetAddress();
                if (label == null || label.trim().isEmpty()) label = oldAddr.getLabel();
                if (wardCode == null || wardCode.trim().isEmpty()) wardCode = oldAddr.getWardCode();

                UserAddress addr = new UserAddress();
                addr.setId(addressId);
                addr.setUserId(user.getId());
                addr.setFullName(fullName);
                addr.setPhoneNumber(phone);
                addr.setProvince(province);
                addr.setDistrict(district);
                addr.setWard(ward);
                addr.setStreetAddress(street);
                addr.setLabel(label);

                if (districtIdStr != null && !districtIdStr.isEmpty()) {
                    addr.setDistrictId(Integer.parseInt(districtIdStr));
                } else {
                    addr.setDistrictId(oldAddr.getDistrictId());
                }
                if (wardCode == null || wardCode.trim().isEmpty()) {
                    wardCode = oldAddr.getWardCode();
                }
                addr.setWardCode(wardCode);
                if (!userDAO.isValidCarrier(phone.trim())) {
                    session.setAttribute("msg", "Số điện thoại không hợp lệ!");
                    session.setAttribute("msgType", "danger");
                    response.sendRedirect(request.getContextPath() + "/dia-chi-nguoi-dung");
                    return;
                }
                boolean ok = dao.updateAddress(addr);
                if (ok) {
                    session.setAttribute("msg", "Cập nhật địa chỉ thành công!");
                    session.setAttribute("msgType", "success");
                } else {
                    session.setAttribute("msg", "Cập nhật thất bại!");
                    session.setAttribute("msgType", "danger");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean ok = dao.deleteAddress(id, user.getId());
            if (ok) {
                session.setAttribute("msg", "Xóa địa chỉ thành công!");
                session.setAttribute("msgType", "success");
            } else {
                session.setAttribute("msg", "Không thể xóa địa chỉ này!");
                session.setAttribute("msgType", "danger");
            }

        } else if ("set_default".equals(action)) {
            int id = Integer.parseInt(request.getParameter("defaultAddressId"));
            boolean ok = dao.setDefaultAddress(id, user.getId());
            if (ok) {
                session.setAttribute("msg", "Đã thiết lập địa chỉ mặc định thành công!");
                session.setAttribute("msgType", "success");
            } else {
                session.setAttribute("msg", "Thiết lập mặc định thất bại!");
                session.setAttribute("msgType", "danger");
            }
        }
        response.sendRedirect(request.getContextPath() + "/dia-chi-nguoi-dung");
    }
}
