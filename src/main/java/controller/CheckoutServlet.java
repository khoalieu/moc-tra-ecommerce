package controller;

import dao.*;
import model.cart.Cart;
import model.cart.CartItem;
import model.promotion.VipVoucher;
import model.user.User;
import model.user.UserAddress;
import model.order.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CheckoutServlet", value = "/thanh-toan")
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Cart cart = (Cart) session.getAttribute("cart");

        // 1. Kiểm tra điều kiện đầu vào
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }
        if (cart == null || cart.getTotalQuantity() == 0) {
            response.sendRedirect(request.getContextPath() + "/san-pham");
            return;
        }

        // Trong doGet của CheckoutServlet
        String[] selectedItems = request.getParameterValues("selectedItems");

        if (selectedItems != null && selectedItems.length > 0) {
            // Nếu đi từ giỏ hàng sang, lưu vào Session
            session.setAttribute("selectedItemIds", selectedItems);
        } else {
            // Nếu trang reload (do chọn phí ship), lấy từ Session ra
            selectedItems = (String[]) session.getAttribute("selectedItemIds");
        }

        // Nếu cả 2 đều null thì mới văng về giỏ hàng
        if (selectedItems == null) {
            response.sendRedirect(request.getContextPath() + "/gio-hang");
            return;
        }

        // 2. Tính Tạm tính (Subtotal)
        double subtotal = 0;
        List<CartItem> checkoutItems = new ArrayList<>();
        for (CartItem item : cart.getItems()) {
            for (String selectedId : selectedItems) {
                if (item.getVariantId() == Integer.parseInt(selectedId)) {
                    checkoutItems.add(item);
                    subtotal += item.getTotalPrice();
                    break;
                }
            }
        }

        // 3. Tính phí vận chuyển gốc theo tỉnh (Base Fee)
        UserAddressDAO addressDAO = DAOFactory.getInstance().getUserAddressDAO();
        List<UserAddress> addresses = addressDAO.getListAddress(user.getId());

        // Ưu tiên địa chỉ mặc định
        UserAddress currentAddr = null;
        if (addresses != null && !addresses.isEmpty()) {
            // Tìm địa chỉ mặc định bằng vòng lặp for cho chắc chắn
            for (UserAddress a : addresses) {
                if (a.getIsDefault()) {
                    currentAddr = a;
                    break;
                }
            }
            // Nếu không có cái nào mặc định, lấy cái đầu tiên trong danh sách
            if (currentAddr == null) {
                currentAddr = addresses.get(0);
            }
        }

        double baseFee = 30000; // Giá mặc định nếu không tìm thấy tỉnh
        if (currentAddr != null) {
            ShippingDAO shippingDAO = DAOFactory.getInstance().getShippingDAO();
            baseFee = shippingDAO.getFeeByProvince(currentAddr.getProvince());
        }

        // 4. Đưa dữ liệu sang JSP
        request.setAttribute("addresses", addresses);
        request.setAttribute("checkoutItems", checkoutItems);
        request.setAttribute("subtotal", subtotal);

        // Gửi phí bóc tách
        request.setAttribute("baseProvinceFee", baseFee); // Ví dụ: 35000 cho Hà Nội
        request.setAttribute("extraShippingFee", 0);      // Mặc định ban đầu là Tiêu chuẩn (0đ)

        // Tổng cộng ban đầu
        request.setAttribute("totalAmount", subtotal + baseFee);

        // 5. Xử lý VIP Voucher
        if (Boolean.TRUE.equals(user.getIsVip())) {
            VipVoucherDAO voucherDAO = DAOFactory.getInstance().getVipVoucherDAO();
            List<VipVoucher> userVipVouchers = voucherDAO.getActiveVouchersForUser(user.getId());
            request.setAttribute("userVipVouchers", userVipVouchers);
        }

        request.getRequestDispatcher("/cart/thanh-toan.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if ("calculate".equals(action)) {
            // Đẩy ngược các giá trị người dùng đã nhập vào attribute để JSP lấy lại được
            request.setAttribute("savedFullName", request.getParameter("fullName"));
            request.setAttribute("savedPhone", request.getParameter("phoneNumber"));
            request.setAttribute("savedNote", request.getParameter("note"));
            request.setAttribute("savedAddressId", request.getParameter("selectedAddress"));
            // Tương tự cho province, ward, addressLine nếu cần

            doGet(request, response);
            return;
        }
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Cart cart = (Cart) session.getAttribute("cart");
        String[] selectedItemIds = (String[]) session.getAttribute("selectedItemIds");

        if (user == null || cart == null || cart.getTotalQuantity() == 0 || selectedItemIds == null || selectedItemIds.length == 0) {
            response.sendRedirect(request.getContextPath() + "/gio-hang");
            return;
        }

        String selectedAddressVal = request.getParameter("selectedAddress");
        String shippingMethod = request.getParameter("shippingMethod");
        String paymentMethod = request.getParameter("paymentMethod");
        String note = request.getParameter("note");
        UserAddressDAO addressDAO = DAOFactory.getInstance().getUserAddressDAO();
        int shippingAddressId = 0;

        if ("new".equals(selectedAddressVal)) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phoneNumber");
            String province = request.getParameter("province");
            String ward = request.getParameter("ward");
            String street = request.getParameter("addressLine");

            UserAddress newAddr = new UserAddress();
            newAddr.setUserId(user.getId());
            newAddr.setFullName(fullName);
            newAddr.setPhoneNumber(phone);
            newAddr.setLabel("Địa chỉ mới");
            newAddr.setProvince(province);
            newAddr.setWard(ward);
            newAddr.setStreetAddress(street);
            newAddr.setIsDefault(false);
            shippingAddressId = addressDAO.addAddressAndGetId(newAddr);

            if (shippingAddressId <= 0) {
                request.setAttribute("errorMessage", "Không thể lưu địa chỉ mới. Vui lòng kiểm tra lại thông tin!");
                doGet(request, response);
                return;
            }
        } else {
            try {
                shippingAddressId = Integer.parseInt(selectedAddressVal);
            } catch (NumberFormatException e) {
                shippingAddressId = 0;
            }
        }

        List<CartItem> selectedCartItems = new ArrayList<>();
        double subtotal = 0;
        for (CartItem item : cart.getItems()) {
            for (String idStr : selectedItemIds) {
                if (item.getVariantId() == Integer.parseInt(idStr)) {
                    selectedCartItems.add(item);
                    subtotal += item.getTotalPrice();
                    break;
                }
            }
        }

        // 3. Tính giảm giá VIP (Voucher)
        double vipDiscount = 0;
        Integer appliedVoucherId = null;
        String applyVipVoucher = request.getParameter("applyVipVoucher");
        String selectedVoucherId = request.getParameter("selectedVoucher");
        if ("true".equals(applyVipVoucher)
                && selectedVoucherId != null
                && !selectedVoucherId.isEmpty()
                && Boolean.TRUE.equals(user.getIsVip())) {
            try {
                int voucherId = Integer.parseInt(selectedVoucherId);
                VipVoucherDAO voucherDAO = DAOFactory.getInstance().getVipVoucherDAO();
                VipVoucher voucher = voucherDAO.getActiveVoucherForUser(user.getId(), voucherId);

                if (voucher != null) {
                    if ("PERCENT".equals(voucher.getDiscountType())) {
                        vipDiscount = subtotal * voucher.getDiscountValue() / 100.0;
                    } else if ("FIXED_AMOUNT".equals(voucher.getDiscountType())) {
                        vipDiscount = voucher.getDiscountValue();
                    }

                    if (vipDiscount > subtotal) {
                        vipDiscount = subtotal;
                    }

                    appliedVoucherId = voucherId;
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // 4. Tính phí vận chuyển (Shipping Fee)
        UserAddress addr = addressDAO.getAddressById(shippingAddressId);
        ShippingDAO shippingDAO = DAOFactory.getInstance().getShippingDAO();

        double provinceFee = 30000; // Mặc định nếu không tìm thấy
        if (addr != null && addr.getProvince() != null) {
            provinceFee = shippingDAO.getFeeByProvince(addr.getProvince());
        }

        double serviceFee = 0;
        if ("express".equals(shippingMethod)) {
            serviceFee = 15000;
        } else if ("instant".equals(shippingMethod)) {
            serviceFee = 30000;
        }

        double finalShippingFee = provinceFee + serviceFee;

        // 5. Tổng tiền cuối cùng
        double totalAmount = subtotal - vipDiscount + finalShippingFee;
        if (totalAmount < 0) totalAmount = 0;

        if (shippingAddressId <= 0) {
            request.setAttribute("errorMessage", "Vui lòng chọn hoặc nhập địa chỉ giao hàng!");
            doGet(request, response);
            return;
        }

        Order order = new Order();
        order.setUserId(user.getId());
        order.setShippingAddressId(shippingAddressId);
        order.setOrderNumber(generateOrderNumber());
        order.setTotalAmount(totalAmount);
        order.setShippingFee(finalShippingFee);
        order.setPaymentMethod(paymentMethod);
        order.setNotes(note);
        OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
        int orderId = orderDAO.createOrder(order);

        if (orderId > 0) {
            orderDAO.addOrderItems(orderId, selectedCartItems);

            ProductVariantDAO variantDAO = DAOFactory.getInstance().getProductVariantDAO();
            CartDAO cartDAO = DAOFactory.getInstance().getCartDAO();

            for (CartItem item : selectedCartItems) {
                variantDAO.decreaseStock(item.getVariantId(), item.getQuantity());

                cartDAO.removeProduct(user.getId(), item.getVariantId());
            }

            if (appliedVoucherId != null) {
                VipVoucherDAO voucherDAO = DAOFactory.getInstance().getVipVoucherDAO();
                voucherDAO.incrementVoucherUsage(appliedVoucherId);
                voucherDAO.markVoucherUsed(user.getId(), appliedVoucherId);
            }
            cart.removeItems(selectedItemIds);
            session.setAttribute("cart", cart);
            session.removeAttribute("selectedItemIds");

            response.sendRedirect("hoa-don?id=" + orderId);
        } else {
            request.setAttribute("errorMessage", "Đặt hàng thất bại. Vui lòng thử lại.");
            doGet(request, response);
        }
    }

    private String generateOrderNumber() {
        return "ORD" + System.currentTimeMillis();
    }
}