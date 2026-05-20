package controller;

import model.SystemLog;
import service.SystemLogService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/system-logs")
public class SystemLogServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        SystemLogService logService = new SystemLogService();
        List<SystemLog> logs = logService.getAllLogs();
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("/admin/system-logs.jsp")
                .forward(request, response);
    }
}