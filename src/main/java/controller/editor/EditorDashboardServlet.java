package controller.editor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "EditorDashboardServlet", urlPatterns = {"/editor/dashboard"})
public class EditorDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        request.getRequestDispatcher("/editor/editor-dashboard.jsp").forward(request, response);
    }
}