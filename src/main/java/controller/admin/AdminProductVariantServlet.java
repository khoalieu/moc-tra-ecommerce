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
        String[] variantSkus = request.getParameterValues("variantSkus");
        String[] variantPrices = request.getParameterValues("variantPrices");
        String[] variantSalePrices = request.getParameterValues("variantSalePrices");
        String[] variantStocks = request.getParameterValues("variantStocks");
        List<ProductVariant> oldVariants = variantDAO.getVariantsByProductId(productId);

        List<Integer> keptIds = new ArrayList<>();
        int savedVariantCount = 0;

        if (variantNames != null) {
            for (int i = 0; i < variantNames.length; i++) {
                if (variantNames[i] == null || variantNames[i].trim().isEmpty()) continue;

                ProductVariant v = new ProductVariant();
                v.setProductId(productId);
                v.setVariantName(variantNames[i].trim());
                v.setSku(variantSkus != null && variantSkus.length > i ? normalizeSku(variantSkus[i]) : null);
                double price = parseDouble(variantPrices[i]);
                double salePrice = parseDouble(variantSalePrices[i]);
                if (salePrice > price) {
                    salePrice = price;
                }
                v.setPrice(price);
                v.setSalePrice(salePrice);
                v.setStockQuantity(parseInt(variantStocks[i]));

                int vId = parseInt(variantIds != null && variantIds.length > i ? variantIds[i] : "0");

                if (vId > 0) {
                    v.setId(vId);
                    variantDAO.updateVariant(v);
                    keptIds.add(vId);
                } else {
                    variantDAO.addVariant(v);
                }
                savedVariantCount++;
            }
        }
        if (savedVariantCount == 0) {
            ProductVariant v = new ProductVariant();
            v.setProductId(productId);
            v.setVariantName("Mặc định");
            v.setSku(oldVariants.isEmpty() || oldVariants.get(0).getSku() == null
                    ? "P" + productId + "-MD"
                    : oldVariants.get(0).getSku());
            v.setPrice(parseDouble(request.getParameter("price")));
            v.setSalePrice(parseDouble(request.getParameter("sale_price")));
            v.setStockQuantity(parseInt(request.getParameter("stock_quantity")));
            if (oldVariants.isEmpty()) {
                variantDAO.addVariant(v);
            } else {
                v.setId(oldVariants.get(0).getId());
                variantDAO.updateVariant(v);
                keptIds.add(v.getId());
            }
        }
        for (ProductVariant oldV : oldVariants) {
            if (!keptIds.contains(oldV.getId())) {
                variantDAO.deactivateVariant(oldV.getId());
            }
        }
    }

    private String normalizeSku(String s) {
        return s == null || s.trim().isEmpty() ? null : s.trim();
    }

    private double parseDouble(String s) {
        try { return Double.parseDouble(s); } catch (Exception e) { return 0; }
    }

    private int parseInt(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return 0; }
    }
}
