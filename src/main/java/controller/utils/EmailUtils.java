package controller.utils;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.InputStream;
import java.util.Properties;

public class EmailUtils {

    private static String MY_EMAIL;
    private static String MY_PASSWORD;
    static {
        try (InputStream input = EmailUtils.class.getClassLoader().getResourceAsStream("email.properties")) {
            Properties prop = new Properties();
            if (input == null) {
                System.out.println("Xin lỗi, không tìm thấy file email.properties");
            } else {
                prop.load(input);
                MY_EMAIL = prop.getProperty("email.username");
                MY_PASSWORD = prop.getProperty("email.password");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public static boolean sendOTP(String toEmail, String otpCode) {
        if (MY_EMAIL == null || MY_PASSWORD == null) {
            System.out.println("Lỗi: Chưa cấu hình Email hoặc Mật khẩu!");
            return false;
        }
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(MY_EMAIL, MY_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(MY_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Mã xác nhận đăng ký tài khoản Mộc Trà");
            message.setText("Chào bạn,\n\nMã OTP để xác nhận đăng ký tài khoản của bạn là: " + otpCode + "\n\nMã này sẽ hết hạn khi bạn đóng trình duyệt.\nCảm ơn bạn đã đồng hành cùng Mộc Trà!");

            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
}