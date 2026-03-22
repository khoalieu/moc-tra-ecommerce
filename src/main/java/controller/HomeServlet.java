package controller;

import dao.BannerDAO;
import dao.BlogPostDAO;
import dao.ProductDAO;
import model.Banner;
import model.blog.BlogPost;
import model.product.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeServlet", urlPatterns = {"/index", "/trang-chu", ""})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        BannerDAO bannerDAO = new BannerDAO();
        ProductDAO productDAO = new ProductDAO();
        BlogPostDAO blogDAO = new BlogPostDAO();

        List<Banner> listBanners = bannerDAO.getHomeActive();
        request.setAttribute("listBanners", listBanners);

        List<Product> topHerbalTea = productDAO.getBestSellerProducts(1, 4);
        List<Product> topMilkTeaIngredients = productDAO.getBestSellerProducts(2, 4);

        request.setAttribute("topHerbalTea", topHerbalTea);
        request.setAttribute("topMilkTeaIngredients", topMilkTeaIngredients);

        try {
            List<BlogPost> topBlogs = blogDAO.getTopViewedPublished(3);
            request.setAttribute("topBlogs", topBlogs);
        } catch (Exception e) {
        }

        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}