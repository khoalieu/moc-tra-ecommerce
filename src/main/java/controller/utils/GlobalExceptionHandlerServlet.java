package controller.utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.SystemLogService;
import model.user.User;

import java.io.IOException;

@WebServlet(name = "GlobalExceptionHandlerServlet", value = "/errorHandler")
public class GlobalExceptionHandlerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        handleException(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        handleException(request, response);
    }

    private void handleException(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Throwable throwable = (Throwable) request.getAttribute("jakarta.servlet.error.exception");
        Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
        String servletName = (String) request.getAttribute("jakarta.servlet.error.servlet_name");
        String requestUri = (String) request.getAttribute("jakarta.servlet.error.request_uri");

        if (statusCode == null) {
            statusCode = 500;
        }
        if (requestUri == null) {
            requestUri = "N/A";
        }

        String exceptionMessage = (throwable != null) ? throwable.getMessage() : "Unknown exception";
        String logMessage = String.format("HTTP %d error at URI: %s. Servlet: %s. Message: %s", 
                statusCode, requestUri, servletName != null ? servletName : "N/A", exceptionMessage);
        
        LogService.logError(logMessage, throwable);

        try {
            SystemLogService systemLogService = new SystemLogService();
            Integer userId = null;
            Object userObj = request.getSession().getAttribute("user");
            if (userObj instanceof User) {
                userId = ((User) userObj).getId();
            }
            
            String dbAction = String.format("System Error %d at %s", statusCode, requestUri);
            if (throwable != null) {
                dbAction += ": " + exceptionMessage;
            }
            if (dbAction.length() > 250) {
                dbAction = dbAction.substring(0, 247) + "...";
            }
            systemLogService.log(userId, dbAction, "SystemError", null);
        } catch (Exception e) {
            System.err.println("Failed to insert system error log to Database");
            e.printStackTrace();
        }

        request.getRequestDispatcher("/errors/500.jsp").forward(request, response);
    }
}
