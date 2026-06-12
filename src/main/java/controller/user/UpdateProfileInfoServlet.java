package controller.user;

import dao.DAOFactory;
import dao.UserDAO;
import controller.utils.RedirectUtils;
import controller.utils.CloudinaryUtil;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import model.user.User;
import model.enums.UserGender;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import service.NotificationService;
import java.util.regex.Pattern;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.UUID;

@WebServlet(name = "UpdateProfileInfoServlet", value = "/tai-khoan-cua-toi")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 1024 * 1024 * 5,         // 5 MB
    maxRequestSize = 1024 * 1024 * 10      // 10 MB
)
public class UpdateProfileInfoServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "D:/web_data";
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"};
    private static final String PROFILE_PAGE = "/user/thong-tin-tai-khoan-nguoi-dung.jsp";
    private final UserDAO userDAO = DAOFactory.getInstance().getUserDAO();
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(RedirectUtils.toLoginWithRedirect(request, "/tai-khoan-cua-toi"));
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
            response.sendRedirect(RedirectUtils.toLoginWithRedirect(request, "/tai-khoan-cua-toi"));
            return;
        }

        String firstName = request.getParameter("firstname");
        String lastName = request.getParameter("lastname");
        String phone = request.getParameter("phone");
        String dobStr = request.getParameter("dob");
        String genderRaw = request.getParameter("gender");
        String action = request.getParameter("action");

        if ("uploadAvatar".equals(action)) {
            handleAvatarUpload(request, response, user, session);
            return;
        } else if ("removeAvatar".equals(action)) {
            handleAvatarRemove(request, response, user, session);
            return;
        } else {
            handleInfoUpdate(request, response, user, session);
        }
    }

    private void handleInfoUpdate(HttpServletRequest request, HttpServletResponse response, User user, HttpSession session) throws IOException {
        String firstName = request.getParameter("firstname");
        String lastName = request.getParameter("lastname");
        String phone = request.getParameter("phone");
        String dobStr = request.getParameter("dob");
        String genderRaw = request.getParameter("gender");

        if (firstName == null || firstName.trim().isEmpty() || firstName.trim().length() > 50) {
            session.setAttribute("msg", "Tên không hợp lệ (không được để trống và không vượt quá 50 ký tự)!");
            session.setAttribute("msgType", "danger");
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
            return;
        }
        if (lastName == null || lastName.trim().isEmpty() || lastName.trim().length() > 50) {
            session.setAttribute("msg", "Họ không hợp lệ (không được để trống và không vượt quá 50 ký tự)!");
            session.setAttribute("msgType", "danger");
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
            return;
        }
        firstName = firstName.trim();
        lastName = lastName.trim();

        UserDAO dao = DAOFactory.getInstance().getUserDAO();

        if (phone != null && !phone.trim().isEmpty()) {
            String cleanPhone = phone.trim();
            if (!cleanPhone.matches("^[0-9]{10}$")) {
                session.setAttribute("msg", "Số điện thoại không hợp lệ (phải gồm 10 chữ số)!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                return;
            } else if (!Pattern.matches(UserDAO.PHONE_REGEX, cleanPhone)) {
                session.setAttribute("msg", "Số điện thoại không đúng định dạng nhà mạng Việt Nam!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                return;
            } else if (!dao.isValidCarrier(cleanPhone)) {
                session.setAttribute("msg", "Đầu số nhà mạng không tồn tại!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                return;
            }
            phone = cleanPhone;
        }

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
            } catch (Exception e) {
                session.setAttribute("msg", "Định dạng ngày tháng không đúng!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                return;
            }
        }
        try {
            String genderForDb = (genderRaw != null) ? genderRaw.toLowerCase() : "other";
            if (dao.updateProfile(firstName, lastName, phone, dobStr, genderForDb, user.getId())) {
                user.setFirstName(firstName);
                user.setLastName(lastName);
                user.setPhone(phone);
                if (validatedDob != null) user.setDateOfBirth(validatedDob.atStartOfDay());
                if (genderRaw != null) user.setGender(UserGender.valueOf(genderRaw.toUpperCase()));
                
                session.setAttribute("user", user);
                new NotificationService().notifyProfileUpdated(user.getId(),
                        "Thông tin cá nhân của bạn vừa được cập nhật thành công.");
                session.setAttribute("msg", "Cập nhật thông tin thành công!");
                session.setAttribute("msgType", "success");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
    }

    /**
     * Handles avatar image upload.
     */
    private void handleAvatarUpload(HttpServletRequest request, HttpServletResponse response, User currentUser, HttpSession session)
            throws ServletException, IOException {
        try {
            Part filePart = request.getPart("avatar");
            
            if (filePart == null || filePart.getSize() == 0) {
                session.setAttribute("msg", "Vui lòng chọn một file ảnh để tải lên!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                return;
            }

            String fileName = getSubmittedFileName(filePart);
            String extension = getFileExtension(fileName).toLowerCase();

            // Validate file extension
            if (!isAllowedExtension(extension)) {
                session.setAttribute("msg", "Định dạng file không hợp lệ! Chỉ chấp nhận các định dạng JPG, PNG, GIF, và WebP.");
                session.setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                return;
            }
            if (filePart.getSize() > 2 * 1024 * 1024) {
                session.setAttribute("msg", "Kích thước ảnh đại diện tối đa là 2MB!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                return;
            }

            // Upload to Cloudinary using an InputStream
            String secureUrl = null;
            try (InputStream input = filePart.getInputStream()) {
                String publicId = "avatar_" + currentUser.getId() + "_" + UUID.randomUUID().toString().substring(0, 8);
                secureUrl = CloudinaryUtil.uploadFile(input, "avatars", publicId);
            }

            if (secureUrl == null || secureUrl.isEmpty()) {
                throw new Exception("Cloudinary secure_url is empty");
            }

            // Delete old avatar from Cloudinary or Local
            if (currentUser.getAvatar() != null && currentUser.getAvatar().startsWith("http")) {
                try {
                    String oldUrl = currentUser.getAvatar();
                    int avatarsIndex = oldUrl.indexOf("avatars/");
                    if (avatarsIndex != -1) {
                        int dotIndex = oldUrl.lastIndexOf('.');
                        if (dotIndex != -1 && dotIndex > avatarsIndex) {
                            String oldPublicId = oldUrl.substring(avatarsIndex, dotIndex);
                            CloudinaryUtil.deleteFile(oldPublicId);
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Warning: failed to delete old avatar from Cloudinary: " + e.getMessage());
                }
            } else if (currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty()) {
                File oldFile = new File(UPLOAD_DIR + File.separator + currentUser.getAvatar());
                if (oldFile.exists()) {
                    oldFile.delete();
                }
            }

            userDAO.updateAvatar(currentUser.getId(), secureUrl);
            User updatedUser = userDAO.getUserDetailById(currentUser.getId());
            session.setAttribute("user", updatedUser);
            new NotificationService().notifyProfileUpdated(currentUser.getId(),
                    "Ảnh đại diện của bạn vừa được cập nhật thành công.");
            
            session.setAttribute("msg", "Cập nhật ảnh đại diện thành công!");
            session.setAttribute("msgType", "success");
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg", "Tải ảnh đại diện thất bại!");
            session.setAttribute("msgType", "danger");
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
        }
    }

    /**
     * Handles avatar removal.
     */
    private void handleAvatarRemove(HttpServletRequest request, HttpServletResponse response, User currentUser, HttpSession session)
            throws ServletException, IOException {
        try {
            if (currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty()) {
                if (currentUser.getAvatar().startsWith("http")) {
                    try {
                        String oldUrl = currentUser.getAvatar();
                        int avatarsIndex = oldUrl.indexOf("avatars/");
                        if (avatarsIndex != -1) {
                            int dotIndex = oldUrl.lastIndexOf('.');
                            if (dotIndex != -1 && dotIndex > avatarsIndex) {
                                String oldPublicId = oldUrl.substring(avatarsIndex, dotIndex);
                                CloudinaryUtil.deleteFile(oldPublicId);
                            }
                        }
                    } catch (Exception e) {
                        System.err.println("Warning: failed to delete avatar from Cloudinary: " + e.getMessage());
                    }
                } else {
                    File avatarFile = new File(UPLOAD_DIR + File.separator + currentUser.getAvatar());
                    if (avatarFile.exists()) {
                        avatarFile.delete();
                    }
                }
            }
            userDAO.updateAvatar(currentUser.getId(), null);

            User updatedUser = userDAO.getUserDetailById(currentUser.getId());
            session.setAttribute("user", updatedUser);
            new NotificationService().notifyProfileUpdated(currentUser.getId(),
                    "Ảnh đại diện của bạn vừa được xóa.");

            session.setAttribute("msg", "Đã xóa ảnh đại diện!");
            session.setAttribute("msgType", "success");
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg", "Xóa ảnh đại diện thất bại!");
            session.setAttribute("msgType", "danger");
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
        }
    }

    /**
     * Gets the file extension from a filename.
     */
    private String getFileExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf("."));
    }

    /**
     * Checks if the file extension is allowed.
     */
    private boolean isAllowedExtension(String extension) {
        for (String allowed : ALLOWED_EXTENSIONS) {
            if (allowed.equalsIgnoreCase(extension)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Gets the submitted file name from the Part.
     */
    private String getSubmittedFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}
