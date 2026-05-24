package controller;

import dao.BlogPostDAO;
import dao.DAOFactory;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.blog.BlogPost;
import model.product.Product;

import java.io.IOException;
import java.util.List;

@WebServlet("/search-suggestions")
public class SearchSuggestionServlet extends HttpServlet {

    private ProductDAO productDAO;
    private BlogPostDAO blogPostDAO;

    @Override
    public void init() throws ServletException {
        productDAO = DAOFactory.getInstance().getProductDAO();
        blogPostDAO = DAOFactory.getInstance().getBlogPostDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String keyword = request.getParameter("keyword");

        if (keyword == null || keyword.trim().isEmpty()) {
            response.getWriter().write("{\"products\":[],\"blog\":null}");
            return;
        }

        List<Product> products = productDAO.searchProductSuggestions(keyword, 5);
        BlogPost blog = blogPostDAO.searchBlogSuggestion(keyword);

        StringBuilder json = new StringBuilder();

        json.append("{");

        json.append("\"products\":[");
        for (int i = 0; i < products.size(); i++) {
            Product p = products.get(i);

            if (i > 0) {
                json.append(",");
            }

            double displayPrice = p.getSalePrice() > 0 ? p.getSalePrice() : p.getPrice();

            json.append("{");
            json.append("\"id\":").append(p.getId()).append(",");
            json.append("\"name\":\"").append(escapeJson(p.getName())).append("\",");
            json.append("\"imageUrl\":\"").append(escapeJson(p.getImageUrl())).append("\",");
            json.append("\"price\":").append(displayPrice);
            json.append("}");
        }
        json.append("],");

        json.append("\"blog\":");
        if (blog != null) {
            json.append("{");
            json.append("\"id\":").append(blog.getId()).append(",");
            json.append("\"title\":\"").append(escapeJson(blog.getTitle())).append("\",");
            json.append("\"slug\":\"").append(escapeJson(blog.getSlug())).append("\",");
            json.append("\"imageUrl\":\"").append(escapeJson(blog.getFeaturedImage())).append("\"");
            json.append("}");
        } else {
            json.append("null");
        }

        json.append("}");

        response.getWriter().write(json.toString());
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "")
                .replace("\r", "");
    }
}