package controller.user;

import dao.DAOFactory;
import dao.UserDAO;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import model.user.User;
import model.enums.UserGender;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;

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

        UserDAO dao = DAOFactory.getInstance().getUserDAO();
        try {
            String genderForDb = (genderRaw != null) ? genderRaw.toLowerCase() : "other";
            if (dao.updateProfile(firstName, lastName, phone, dobStr, genderForDb, user.getId())) {
                // Cập nhật lại object user trong session
                user.setFirstName(firstName);
                user.setLastName(lastName);
                user.setPhone(phone);
                if (validatedDob != null) user.setDateOfBirth(validatedDob.atStartOfDay());
                if (genderRaw != null) user.setGender(UserGender.valueOf(genderRaw.toUpperCase()));
                
                session.setAttribute("user", user);
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
                request.setAttribute("error", "Please select an image file to upload.");
                request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
                return;
            }

            String fileName = getSubmittedFileName(filePart);
            String extension = getFileExtension(fileName).toLowerCase();

            // Validate file extension
            if (!isAllowedExtension(extension)) {
                request.setAttribute("error", "Invalid file type. Only JPG, PNG, GIF, and WebP are allowed.");
                request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
                return;
            }

            // Validate file size (additional check)
            if (filePart.getSize() > 5 * 1024 * 1024) {
                request.setAttribute("error", "File size must be less than 5MB.");
                request.getRequestDispatcher(PROFILE_PAGE).forward(request, response);
                return;
            }

            // Create upload directory if it doesn't exist
            String uploadPath = UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Xóa ảnh cũ (nếu có)
            if (currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty()) {
                // Sửa lại cách lấy đường dẫn file cũ để xóa
                File oldFile = new File(uploadPath + File.separator + currentUser.getAvatar());
                if (oldFile.exists()) {
                    oldFile.delete();
                }
            }

            // 1. Tạo tên file đầy đủ có cả đuôi file
            String uniqueFileName = "avatar_" + currentUser.getId() + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;

            // 2. Lưu file vào ổ đĩa
            Path filePath = Paths.get(uploadPath, uniqueFileName);
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
            }

            // Cập nhật Database với ĐẦY ĐỦ tên file (uniqueFileName)
            // Hãy đảm bảo biến uniqueFileName truyền vào đây có đuôi .png/.jpg
            userDAO.updateAvatar(currentUser.getId(), uniqueFileName);
            // Refresh user from database and update session
            User updatedUser = userDAO.getUserDetailById(currentUser.getId());
            session.setAttribute("user", updatedUser); 
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi?success=avatar_updated");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi?error=upload_failed");
        }
    }

    /**
     * Handles avatar removal.
     */
    private void handleAvatarRemove(HttpServletRequest request, HttpServletResponse response, User currentUser, HttpSession session)
            throws ServletException, IOException {
        try {
            // Delete file if exists
            if (currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty()) {
                // Trỏ thẳng vào thư mục ngoài để xóa
                File avatarFile = new File(UPLOAD_DIR + File.separator + currentUser.getAvatar());
                if (avatarFile.exists()) {
                    avatarFile.delete();
                }
            }
            // Update database
            userDAO.updateAvatar(currentUser.getId(), null);

            // Refresh user from database and update session
            User updatedUser = userDAO.getUserDetailById(currentUser.getId());
            session.setAttribute("user", updatedUser);

            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi?success=avatar_removed");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi?error=remove_failed");
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
