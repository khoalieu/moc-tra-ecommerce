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
        Sheet sheet = workbook.createSheet("Products");

        Row header = sheet.createRow(0);

        String[] columns = {
                "Name",
                "Price",
                "SalePrice",
                "Stock",
                "Category",
                "Status",
                "IsBestseller",
                "ShortDescription",
                "Description"
        };

        for (int i = 0; i < columns.length; i++) {
            Cell cell = header.createCell(i);
            cell.setCellValue(columns[i]);
            sheet.autoSizeColumn(i);
        }

        Row sample = sheet.createRow(1);
        sample.createCell(0).setCellValue("Trà đào cam sả");
        sample.createCell(1).setCellValue(35000);
        sample.createCell(2).setCellValue(30000);
        sample.createCell(3).setCellValue(50);
        sample.createCell(4).setCellValue("Trà trái cây");
        sample.createCell(5).setCellValue("ACTIVE");
        sample.createCell(6).setCellValue("false");
        sample.createCell(7).setCellValue("Mô tả ngắn sản phẩm");
        sample.createCell(8).setCellValue("Mô tả chi tiết sản phẩm");

        workbook.write(response.getOutputStream());
        workbook.close();
    }
}