package controller.utils;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;

public class EmailService {
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static String EMAIL_USERNAME;
    private static String EMAIL_PASSWORD;

    static {
        try (java.io.InputStream input = EmailService.class.getClassLoader().getResourceAsStream("email.properties")) {
            java.util.Properties prop = new java.util.Properties();
            if (input != null) {
                prop.load(input);
                EMAIL_USERNAME = prop.getProperty("email.username");
                EMAIL_PASSWORD = prop.getProperty("email.password");
                if (EMAIL_PASSWORD != null) {
                    EMAIL_PASSWORD = EMAIL_PASSWORD.replace(" ", "").trim();
                }
            } else {
                System.err.println("====== [LỖI KHÔNG TÌM THẤY FILE EMAIL.PROPERTIES] ======");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public static void sendEmail(String toAddress, String subject, String message) throws MessagingException {
        if (toAddress == null || toAddress.trim().isEmpty()) {
            throw new MessagingException("Địa chỉ email người nhận (toAddress) không được để trống!");
        }
        if (EMAIL_USERNAME == null || EMAIL_USERNAME.trim().isEmpty()) {
            throw new MessagingException("Cấu hình email server bị thiếu: email.username chưa được thiết lập trong email.properties!");
        }
        if (EMAIL_PASSWORD == null || EMAIL_PASSWORD.trim().isEmpty()) {
            throw new MessagingException("Cấu hình email server bị thiếu: email.password chưa được thiết lập trong email.properties!");
        }
        Properties properties = new Properties();
        properties.put("mail.smtp.host", SMTP_HOST);
        properties.put("mail.smtp.port", SMTP_PORT);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        Authenticator auth = new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
            }
        };

        Session session = Session.getInstance(properties, auth);
        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(EMAIL_USERNAME));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toAddress));
        msg.setSubject(subject);
        msg.setText(message);
        Transport.send(msg);
    }
}
