package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;

@WebServlet("/admin/products/inventory-template")
public class ProductInventoryTemplateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=inventory_import_template.xlsx");

        Workbook workbook = new XSSFWorkbook();
        CellStyle headerStyle = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        headerStyle.setFont(font);

        Sheet sheet = workbook.createSheet("Inventory");
        Row header = sheet.createRow(0);
        String[] columns = {
                "variant_id",
                "variant_sku",
                "product_name",
                "variant_name",
                "quantity_add"
        };

        for (int i = 0; i < columns.length; i++) {
            Cell cell = header.createCell(i);
            cell.setCellValue(columns[i]);
            cell.setCellStyle(headerStyle);
        }

        Row sample = sheet.createRow(1);
        sample.createCell(0).setCellValue("");
        sample.createCell(1).setCellValue("TRA001-MD");
        sample.createCell(2).setCellValue("Tra dao cam sa");
        sample.createCell(3).setCellValue("Mac dinh");
        sample.createCell(4).setCellValue(20);

        Row sampleById = sheet.createRow(2);
        sampleById.createCell(0).setCellValue(12);
        sampleById.createCell(1).setCellValue("");
        sampleById.createCell(2).setCellValue("Tra sen vang");
        sampleById.createCell(3).setCellValue("Hop 10 goi");
        sampleById.createCell(4).setCellValue(15);

        for (int i = 0; i < columns.length; i++) {
            sheet.autoSizeColumn(i);
        }

        workbook.write(response.getOutputStream());
        workbook.close();
    }
}
