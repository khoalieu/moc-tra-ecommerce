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
                "Tên sản phẩm",
                "Giá gốc",
                "Giá sale",
                "Số lượng",
                "Danh mục",
                "Trạng thái",
                "Bán chạy",
                "Mô tả ngắn",
                "Mô tả chi tiết",
                "Tệp hình ảnh"
        };

        for (int i = 0; i < columns.length; i++) {
            Cell cell = header.createCell(i);
            cell.setCellValue(columns[i]);
            cell.setCellStyle(headerStyle);
        }

        Row sample = sheet.createRow(1);
        sample.createCell(0).setCellValue("Trà đào cam sả");
        sample.createCell(1).setCellValue(35000);
        sample.createCell(2).setCellValue(30000);
        sample.createCell(3).setCellValue(50);
        sample.createCell(4).setCellValue("Trà trái cây");
        sample.createCell(5).setCellValue("ACTIVE");
        sample.createCell(6).setCellValue("true");
        sample.createCell(7).setCellValue("Trà đào thanh mát");
        sample.createCell(8).setCellValue("Trà đào cam sả phù hợp uống lạnh");
        sample.createCell(9).setCellValue("tra-dao-cam-sa.png");

        for (int i = 0; i < columns.length; i++) {
            sheet.autoSizeColumn(i);
        }

        workbook.write(response.getOutputStream());
        workbook.close();
    }
}