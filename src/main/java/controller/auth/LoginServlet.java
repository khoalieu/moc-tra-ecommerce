package controller.auth;

import dao.CartDAO;
import dao.DAOFactory;
import dao.UserDAO;
import model.cart.Cart;
import model.cart.CartItem;
import model.user.User;
import org.mindrot.jbcrypt.BCrypt; // Import thư viện BCrypt
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.time.LocalDateTime;
import controller.utils.EmailService;
import controller.utils.LogService;

@WebServlet(name = "LoginServlet", value = "/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (request.getSession().getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        String googleLoginUrl = controller.utils.GoogleUtils.getGoogleAuthUrl();
        request.setAttribute("googleUrl", googleLoginUrl);
        request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String loginKey = request.getParameter("username");
        String passParam = request.getParameter("password");

        String genericErrorMessage = "Tên đăng nhập hoặc mật khẩu không chính xác.";

        if (loginKey == null || loginKey.trim().isEmpty() ||
                passParam == null || passParam.isEmpty()) {
            request.setAttribute("username", loginKey != null ? loginKey.trim() : "");
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!");
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        String identifier = loginKey.trim().toLowerCase();
        String password = passParam;

        UserDAO dao = DAOFactory.getInstance().getUserDAO();

        User user = dao.getUserForLogin(identifier);
        if (user == null) {
            request.setAttribute("errorMessage", genericErrorMessage);
            request.setAttribute("username", identifier);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }
        if (user.getLockUntil() != null && user.getLockUntil().isAfter(LocalDateTime.now())) {
            request.setAttribute("errorMessage", genericErrorMessage);
            request.setAttribute("username", identifier);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }
        boolean isVerified = false;
        if (user.getPasswordHash() != null) {
            isVerified = BCrypt.checkpw(password, user.getPasswordHash());
        }

        if (isVerified) {
            dao.resetFailedAttempts(user.getId());

            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            CartDAO cartDAO = DAOFactory.getInstance().getCartDAO();
            Cart sessionCart = (Cart) session.getAttribute("cart");
            if (sessionCart != null && sessionCart.getItems().size() > 0) {
                for (CartItem item : sessionCart.getItems()) {
                    cartDAO.addToCart(user.getId(), item.getProduct().getId(), item.getQuantity());
                }
            }
            Cart userCartFromDB = cartDAO.getCartByUserId(user.getId());
            session.setAttribute("cart", userCartFromDB);
            if (user.getRole() != null && user.getRole().name().equalsIgnoreCase("ADMIN")) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/index");
            }

        } else {
            int currentAttempts = (user.getFailedAttempts() != null) ? user.getFailedAttempts() : 0;
            boolean justLocked = dao.recordFailedAttempt(user.getId(), currentAttempts);
            if (justLocked) {
                String baseURL = request.getScheme() + "://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath();
                sendLockoutEmailAsync(user.getEmail(), user.getUsername(), baseURL);
                logSuspiciousActivity(user.getId(), request.getRemoteAddr());
            }

            request.setAttribute("errorMessage", genericErrorMessage);
            request.setAttribute("username", identifier);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
        }
    }

    private void sendLockoutEmailAsync(String toEmail, String username, String baseUrl) {
        if (toEmail == null || toEmail.trim().isEmpty()) {
            LogService.logWarning("Không thể gửi email cảnh báo: User " + username + " không có địa chỉ email.");
            return;
        }
        new Thread(() -> {
            try {
                String resetLink = baseUrl + "/forgot-password?email=" + toEmail;
                String subject = "Cảnh báo bảo mật: Tài khoản Mộc Trà của bạn bị tạm khóa";
                String content = "Chào " + username + ",\n\n"
                        + "Chúng tôi nhận thấy có quá nhiều lần nhập sai mật khẩu vào tài khoản của bạn. "
                        + "Để bảo vệ an toàn, tài khoản của bạn đã bị khóa tạm thời trong 30 phút.\n\n"
                        + "Nếu đây không phải là bạn, vui lòng truy cập website và tiến hành Đổi mật khẩu/Quên mật khẩu "
                        + "ngay lập tức để đảm bảo an toàn.\n\n"
                        + "Nếu bạn quên mật khẩu, hãy nhấn vào liên kết dưới đây để nhận mã OTP và mở khóa tài khoản ngay:\n"
                        + resetLink + "\n\n"
                        + "Trân trọng,\n"
                        + "Đội ngũ bảo mật Mộc Trà Ecommerce.";
                EmailService.sendEmail(toEmail, subject, content);

                LogService.logInfo("Đã gửi email cảnh báo khóa tài khoản tới: " + toEmail);
            } catch (Exception e) {
                LogService.logError("Lỗi khi gửi email cảnh báo cho: " + toEmail, e);
            }
        }).start();
    }

    private void logSuspiciousActivity(int userId, String ipAddress) {
        String msg = "Tài khoản (User ID: " + userId + ") vừa bị khóa 30 phút do vượt quá số lần đăng nhập sai. IP thực hiện: " + ipAddress;
        LogService.logWarning(msg);
    }
}
