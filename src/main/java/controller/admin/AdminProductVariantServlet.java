package controller.admin;

import dao.DAOFactory;
import dao.ProductVariantDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.product.ProductVariant;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/product/variant/process")
public class AdminProductVariantServlet extends HttpServlet {
    private ProductVariantDAO variantDAO;

    @Override
    public void init() {
        variantDAO = DAOFactory.getInstance().getProductVariantDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int productId = Integer.parseInt(request.getParameter("id"));

        String[] variantIds = request.getParameterValues("variantIds");
        String[] variantNames = request.getParameterValues("variantNames");
        String[] variantPrices = request.getParameterValues("variantPrices");
        String[] variantSalePrices = request.getParameterValues("variantSalePrices");
        String[] variantStocks = request.getParameterValues("variantStocks");
        
        List<ProductVariant> oldVariants = variantDAO.getVariantsByProductId(productId);

        List<Integer> keptIds = new ArrayList<>();
        if (variantNames != null) {
            for (int i = 0; i < variantNames.length; i++) {
                if (variantNames[i] == null || variantNames[i].trim().isEmpty()) continue;

                ProductVariant v = new ProductVariant();
                v.setProductId(productId);
                v.setVariantName(variantNames[i].trim());
                v.setPrice(parseDouble(variantPrices[i]));
                v.setSalePrice(parseDouble(variantSalePrices[i]));
                v.setStockQuantity(parseInt(variantStocks[i]));

                int vId = parseInt(variantIds != null && variantIds.length > i ? variantIds[i] : "0");

                if (vId > 0) {
                    v.setId(vId);
                    variantDAO.updateVariant(v);
                    keptIds.add(vId);
                } else {
                    variantDAO.addVariant(v);
                }
            }
        }
        for (ProductVariant oldV : oldVariants) {
            if (!keptIds.contains(oldV.getId())) {
                variantDAO.deactivateVariant(oldV.getId());
            }
        }
    }

    private double parseDouble(String s) { try { return Double.parseDouble(s); } catch (Exception e) { return 0; } }
    private int parseInt(String s) { try { return Integer.parseInt(s); } catch (Exception e) { return 0; } }
}