package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;

@WebServlet("/admin/products/template")
public class ProductTemplateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=product_import_template.xlsx");
        Workbook workbook = new XSSFWorkbook();
        CellStyle headerStyle = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        headerStyle.setFont(font);
        Sheet sheet = workbook.createSheet("Products");
        Row header = sheet.createRow(0);
        String[] columns = {
                "product_sku",
                "product_name",
                "category_name",
                "status",
                "bestseller",
                "short_description",
                "description",
                "image_file",
                "variant_sku",
                "variant_name",
                "variant_price",
                "variant_sale_price",
                "variant_stock"
        };

        for (int i = 0; i < columns.length; i++) {
            Cell cell = header.createCell(i);
            cell.setCellValue(columns[i]);
            cell.setCellStyle(headerStyle);
        }

        Row sample = sheet.createRow(1);
        sample.createCell(0).setCellValue("TRA001");
        sample.createCell(1).setCellValue("Trà đào cam sả");
        sample.createCell(2).setCellValue("Trà trái cây");
        sample.createCell(3).setCellValue("ACTIVE");
        sample.createCell(4).setCellValue("true");
        sample.createCell(5).setCellValue("Trà đào thanh mát");
        sample.createCell(6).setCellValue("Trà đào cam sả phù hợp uống lạnh");
        sample.createCell(7).setCellValue("tra-dao-cam-sa.png");
        sample.createCell(8).setCellValue("");
        sample.createCell(9).setCellValue("Mặc định");
        sample.createCell(10).setCellValue(35000);
        sample.createCell(11).setCellValue(30000);
        sample.createCell(12).setCellValue(50);

        Row sampleVariant = sheet.createRow(2);
        sampleVariant.createCell(0).setCellValue("TRA001");
        sampleVariant.createCell(1).setCellValue("Trà đào cam sả");
        sampleVariant.createCell(2).setCellValue("Trà trái cây");
        sampleVariant.createCell(3).setCellValue("ACTIVE");
        sampleVariant.createCell(4).setCellValue("true");
        sampleVariant.createCell(5).setCellValue("Trà đào thanh mát");
        sampleVariant.createCell(6).setCellValue("Trà đào cam sả phù hợp uống lạnh");
        sampleVariant.createCell(7).setCellValue("tra-dao-cam-sa.png");
        sampleVariant.createCell(8).setCellValue("TRA001-H10");
        sampleVariant.createCell(9).setCellValue("Hộp 10 gói");
        sampleVariant.createCell(10).setCellValue(90000);
        sampleVariant.createCell(11).setCellValue(80000);
        sampleVariant.createCell(12).setCellValue(20);

        for (int i = 0; i < columns.length; i++) {
            sheet.autoSizeColumn(i);
        }

        workbook.write(response.getOutputStream());
        workbook.close();
    }
}
