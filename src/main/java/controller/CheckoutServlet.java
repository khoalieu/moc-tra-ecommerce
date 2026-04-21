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

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }
        if (cart == null || cart.getTotalQuantity() == 0) {
            response.sendRedirect(request.getContextPath() + "/san-pham");
            return;
        }
        String[] selectedItems = request.getParameterValues("selectedItems");
        if (selectedItems == null || selectedItems.length == 0) {
            response.sendRedirect(request.getContextPath() + "/gio-hang");
            return;
        }
        double subtotal = 0;
        List<CartItem> checkoutItems = new ArrayList<>();
        for (CartItem item : cart.getItems()) {
            for (String selectedId : selectedItems) {
                if (item.getProduct().getId() == Integer.parseInt(selectedId)) {
                    checkoutItems.add(item);
                    subtotal += item.getTotalPrice();
                    break;
                }
            }
        }
        UserAddressDAO addressDAO = new UserAddressDAO();
        List<UserAddress> addresses = addressDAO.getListAddress(user.getId());
        request.setAttribute("addresses", addresses);
        request.setAttribute("checkoutItems", checkoutItems);
        request.setAttribute("subtotal", subtotal);
        double defaultShipping = 20000;
        request.setAttribute("shippingFee", defaultShipping);
        request.setAttribute("totalAmount", subtotal + defaultShipping);
        session.setAttribute("selectedItemIds", selectedItems);

        if (Boolean.TRUE.equals(user.getIsVip())) {
            VipVoucherDAO voucherDAO = new VipVoucherDAO();
            List<VipVoucher> userVipVouchers = voucherDAO.getActiveVouchersForUser(user.getId());
            request.setAttribute("userVipVouchers", userVipVouchers);
        }

        request.getRequestDispatcher("/cart/thanh-toan.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Cart cart = (Cart) session.getAttribute("cart");
        String[] selectedItemIds = (String[]) session.getAttribute("selectedItemIds");

        if (user == null || cart == null || cart.getTotalQuantity() == 0
                || selectedItemIds == null || selectedItemIds.length == 0) {
            response.sendRedirect(request.getContextPath() + "/gio-hang");
            return;
        }
        String selectedAddressVal = request.getParameter("selectedAddress");
        String shippingMethod = request.getParameter("shippingMethod");
        String paymentMethod = request.getParameter("paymentMethod");
        String note = request.getParameter("note");
        UserAddressDAO addressDAO = new UserAddressDAO();
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
                try {
                    int id = Integer.parseInt(idStr);
                    if (item.getProduct().getId() == id) {
                        selectedCartItems.add(item);
                        subtotal += item.getTotalPrice();
                        break;
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        }

        double shippingFee = 20000;
        if ("express".equals(shippingMethod)) {
            shippingFee = 35000;
        } else if ("instant".equals(shippingMethod)) {
            shippingFee = 60000;
        }

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
                VipVoucherDAO voucherDAO = new VipVoucherDAO();
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

        double totalAmount = subtotal - vipDiscount + shippingFee;
        if (totalAmount < 0) {
            totalAmount = 0;
        }

        Order order = new Order();
        order.setUserId(user.getId());
        order.setShippingAddressId(shippingAddressId);
        order.setOrderNumber(generateOrderNumber());
        order.setTotalAmount(totalAmount);
        order.setShippingFee(shippingFee);
        order.setPaymentMethod(paymentMethod);
        order.setNotes(note);
        OrderDAO orderDAO = new OrderDAO();
        int orderId = orderDAO.createOrder(order);

        if (orderId > 0) {
            orderDAO.addOrderItems(orderId, selectedCartItems);

            ProductDAO productDAO = new ProductDAO();
            CartDAO cartDAO = new CartDAO();

            for (CartItem item : selectedCartItems) {
                productDAO.decreaseStock(item.getProduct().getId(), item.getQuantity());
                cartDAO.removeProduct(user.getId(), item.getProduct().getId());
            }

            if (appliedVoucherId != null) {
                VipVoucherDAO voucherDAO = new VipVoucherDAO();
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