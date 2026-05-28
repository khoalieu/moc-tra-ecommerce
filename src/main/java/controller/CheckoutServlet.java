package controller;

import dao.*;
import model.cart.Cart;
import model.cart.CartItem;
import model.payment.PaymentTransaction;
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
import controller.utils.PaymentUtils;
import controller.utils.PaymentResult;
import model.promotion.Coupon;

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
        if (selectedItems != null && selectedItems.length > 0) {
            session.setAttribute("selectedItemIds", selectedItems);
        } else {
            selectedItems = (String[]) session.getAttribute("selectedItemIds");
        }

        if (selectedItems == null || selectedItems.length == 0) {
            response.sendRedirect(request.getContextPath() + "/gio-hang");
            return;
        }

        double subtotal = 0;
        List<CartItem> checkoutItems = new ArrayList<>();
        for (CartItem item : cart.getItems()) {
            for (String selectedId : selectedItems) {
                try {
                    if (item.getVariantId() == Integer.parseInt(selectedId)) {
                        checkoutItems.add(item);
                        subtotal += item.getTotalPrice();
                        break;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }
        if (checkoutItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/gio-hang");
            return;
        }

        UserAddressDAO addressDAO = DAOFactory.getInstance().getUserAddressDAO();
        List<UserAddress> addresses = addressDAO.getListAddress(user.getId());

        UserAddress defaultAddr = null;
        if (addresses != null && !addresses.isEmpty()) {
            for (UserAddress a : addresses) {
                if (a.getIsDefault()) {
                    defaultAddr = a;
                    break;
                }
            }

            if (defaultAddr == null) {
                defaultAddr = addresses.get(0);
            }
        }

        String selectedAddressId = request.getParameter("selectedAddress");
        String provinceFromForm = request.getParameter("province");
        String shippingMethod = request.getParameter("shippingMethod");

        String provinceToCalculate = (provinceFromForm != null && !provinceFromForm.isEmpty())
                ? provinceFromForm
                : (defaultAddr != null ? defaultAddr.getProvince() : "");

        GHNShippingDAO ghnDAO = DAOFactory.getInstance().getGHNShippingDAO();
        long baseProvinceFee = (provinceToCalculate != null && !provinceToCalculate.isEmpty())
                ? ghnDAO.calculateFeeByProvinceName(provinceToCalculate) : 30000;

        double extraFee = 0;

        if ("express".equals(shippingMethod)) {
            extraFee = 15000;
        } else if ("instant".equals(shippingMethod)) {
            extraFee = 30000;
        }

        double shippingFee = baseProvinceFee + extraFee;

        request.setAttribute("addresses", addresses);
        request.setAttribute("checkoutItems", checkoutItems);
        request.setAttribute("subtotal", subtotal);

        request.setAttribute("baseProvinceFee", baseProvinceFee);
        request.setAttribute("extraShippingFee", extraFee);
        request.setAttribute("shippingFee", shippingFee);
        request.setAttribute("totalAmount", subtotal + shippingFee);

        request.setAttribute("selectedAddressId", selectedAddressId);
        request.setAttribute("selectedProvince", provinceFromForm);
        request.setAttribute("selectedMethod", shippingMethod);

        if (Boolean.TRUE.equals(user.getIsVip())) {
            VipVoucherDAO voucherDAO = DAOFactory.getInstance().getVipVoucherDAO();
            List<VipVoucher> userVipVouchers = voucherDAO.getActiveVouchersForUser(user.getId());
            request.setAttribute("userVipVouchers", userVipVouchers);
        }

        CouponDAO couponDAO = DAOFactory.getInstance().getCouponDAO();
        List<Coupon> userCoupons = couponDAO.getUsableCouponsForUser(user.getId(), subtotal);
        request.setAttribute("userCoupons", userCoupons);

        request.getRequestDispatcher("/cart/thanh-toan.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("calculate".equals(action)) {
            request.setAttribute("savedFullName", request.getParameter("fullName"));
            request.setAttribute("savedPhone", request.getParameter("phoneNumber"));
            request.setAttribute("savedNote", request.getParameter("note"));
            request.setAttribute("savedAddressId", request.getParameter("selectedAddress"));
            doGet(request, response);
            return;
        }

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Cart cart = (Cart) session.getAttribute("cart");
        String[] selectedItemIds = (String[]) session.getAttribute("selectedItemIds");

        if (user == null || cart == null || selectedItemIds == null || selectedItemIds.length == 0) {
            response.sendRedirect(request.getContextPath() + "/gio-hang");
            return;
        }

        String selectedAddressVal = request.getParameter("selectedAddress");
        UserAddressDAO addressDAO = DAOFactory.getInstance().getUserAddressDAO();
        int shippingAddressId = 0;

        if ("new".equals(selectedAddressVal)) {
            UserAddress newAddr = new UserAddress();
            newAddr.setUserId(user.getId());
            newAddr.setFullName(request.getParameter("fullName"));
            newAddr.setPhoneNumber(request.getParameter("phoneNumber"));
            newAddr.setProvince(request.getParameter("province"));
            newAddr.setWard(request.getParameter("ward"));
            newAddr.setStreetAddress(request.getParameter("addressLine"));
            newAddr.setLabel("Địa chỉ mới");
            newAddr.setIsDefault(false);
            shippingAddressId = addressDAO.addAddressAndGetId(newAddr);
        } else {
            try {
                shippingAddressId = Integer.parseInt(selectedAddressVal);
            } catch (NumberFormatException e) {
                shippingAddressId = 0;
            }
        }

        if (shippingAddressId <= 0) {
            request.setAttribute("errorMessage", "Vui lòng chọn địa chỉ giao hàng hợp lệ!");
            doGet(request, response);
            return;
        }
        List<CartItem> selectedCartItems = new ArrayList<>();
        double subtotal = 0;
        for (CartItem item : cart.getItems()) {
            for (String idStr : selectedItemIds) {
                try {
                    if (item.getVariantId() == Integer.parseInt(idStr)) {
                        selectedCartItems.add(item);
                        subtotal += item.getTotalPrice();
                        break;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }

        ShippingDAO shippingDAO = DAOFactory.getInstance().getShippingDAO();
        String province = null;
        if ("new".equals(request.getParameter("selectedAddress"))) {
            province = request.getParameter("province");
        } else {
            UserAddress addr = addressDAO.getAddressById(shippingAddressId);
            if (addr != null) {
                province = addr.getProvince();
            }
        }

        String shippingMethod = request.getParameter("shippingMethod");
        double finalShippingFee = calculateFinalShippingFee(province, shippingMethod);

        double vipDiscount = 0;
        Integer appliedVoucherId = null;
        if ("true".equals(request.getParameter("applyVipVoucher")) && Boolean.TRUE.equals(user.getIsVip())) {
            try {
                int vId = Integer.parseInt(request.getParameter("selectedVoucher"));
                VipVoucher voucher = DAOFactory.getInstance()
                        .getVipVoucherDAO()
                        .getActiveVoucherForUser(user.getId(), vId);

                if (voucher != null) {
                    if ("PERCENT".equals(voucher.getDiscountType())) {
                        vipDiscount = subtotal * voucher.getDiscountValue() / 100.0;
                    } else {
                        vipDiscount = voucher.getDiscountValue();
                    }

                    if (vipDiscount > subtotal) {
                        vipDiscount = subtotal;
                    }

                    appliedVoucherId = vId;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        double couponDiscount = 0;
        Integer appliedCouponId = null;
        String appliedCouponCode = null;

        try {
            CouponDAO couponDAO = DAOFactory.getInstance().getCouponDAO();

            String selectedCouponIdStr = request.getParameter("selectedCouponId");
            String manualCouponCode = request.getParameter("manualCouponCode");

            Coupon coupon = null;

            if (selectedCouponIdStr != null && !selectedCouponIdStr.trim().isEmpty()) {
                int selectedCouponId = Integer.parseInt(selectedCouponIdStr);
                coupon = couponDAO.getValidClaimedCouponForCheckout(user.getId(), selectedCouponId, subtotal);
            } else if (manualCouponCode != null && !manualCouponCode.trim().isEmpty()) {
                coupon = couponDAO.getValidCouponByCodeForCheckout(user.getId(), manualCouponCode.trim(), subtotal);
            }

            if (coupon != null) {
                couponDiscount = couponDAO.calculateDiscount(coupon, subtotal);
                appliedCouponId = coupon.getId();
                appliedCouponCode = coupon.getCode();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        double totalAmount = Math.max(0, subtotal - couponDiscount - vipDiscount + finalShippingFee);

        Order order = new Order();
        order.setUserId(user.getId());
        order.setShippingAddressId(shippingAddressId);
        order.setOrderNumber(generateOrderNumber());
        order.setSubtotalAmount(subtotal);
        order.setTotalAmount(totalAmount);
        order.setShippingFee(finalShippingFee);
        order.setCouponId(appliedCouponId);
        order.setCouponCode(appliedCouponCode);
        order.setCouponDiscountAmount(couponDiscount);
        order.setVipDiscountAmount(vipDiscount);
        order.setPaymentMethod(request.getParameter("paymentMethod"));
        order.setNotes(request.getParameter("note"));

        OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
        int orderId = orderDAO.createOrder(order);

        if (orderId > 0) {
            orderDAO.addOrderItems(orderId, selectedCartItems);

            ProductVariantDAO vDAO = DAOFactory.getInstance().getProductVariantDAO();
            CartDAO cDAO = DAOFactory.getInstance().getCartDAO();
            for (CartItem item : selectedCartItems) {
                vDAO.decreaseStock(item.getVariantId(), item.getQuantity());
                cDAO.removeProduct(user.getId(), item.getVariantId());
            }

            if (appliedVoucherId != null) {
                VipVoucherDAO vvDAO = DAOFactory.getInstance().getVipVoucherDAO();
                vvDAO.incrementVoucherUsage(appliedVoucherId);
                vvDAO.markVoucherUsed(user.getId(), appliedVoucherId);
            }

            if (appliedCouponId != null) {
                CouponDAO couponDAO = DAOFactory.getInstance().getCouponDAO();
                boolean used = couponDAO.markCouponUsed(user.getId(), appliedCouponId);

                if (!used) {
                    System.out.println("Không thể cập nhật trạng thái đã dùng cho couponId = " + appliedCouponId);
                }
            }

            cart.removeItems(selectedItemIds);
            session.setAttribute("cart", cart);
            session.removeAttribute("selectedItemIds");

            String paymentMethod = request.getParameter("paymentMethod");

            if (paymentMethod == null) {
                paymentMethod = "cod";
            }

            if (!"cod".equals(paymentMethod)) {
                try {
                    Order createdOrder = orderDAO.getOrderById(orderId);

                    PaymentResult res = "bank".equals(paymentMethod)
                            ? PaymentUtils.createPayosPayment(createdOrder)
                            : PaymentUtils.createMomoPayment(createdOrder);

                    if (res != null) {
                        PaymentTransaction tx = new PaymentTransaction();
                        tx.setOrderId(orderId);
                        tx.setPaymentMethod(paymentMethod);
                        tx.setProvider(res.getProvider());
                        tx.setRequestId(res.getRequestId());
                        tx.setAmount(totalAmount);
                        tx.setQrCodeUrl(res.getQrCodeUrl());
                        tx.setPayUrl(res.getPayUrl());
                        tx.setTransactionStatus("pending");

                        DAOFactory.getInstance().getPaymentTransactionDAO().create(tx);
                        response.sendRedirect("thanh-toan-qr?orderId=" + orderId);
                        return;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect("hoa-don?id=" + orderId);
        } else {
            request.setAttribute("errorMessage", "Lỗi khi tạo đơn hàng. Vui lòng thử lại!");
            doGet(request, response);
        }
    }

    private double calculateFinalShippingFee(String province, String shippingMethod) {
        GHNShippingDAO ghnDAO = DAOFactory.getInstance().getGHNShippingDAO();
        long provinceFee = 30000;
        if (province != null && !province.isEmpty()) {
            provinceFee = ghnDAO.calculateFeeByProvinceName(province);
        }
        double serviceFee = 0;

        if ("express".equals(shippingMethod)) {
            serviceFee = 15000;
        } else if ("instant".equals(shippingMethod)) {
            serviceFee = 30000;
        }

        return provinceFee + serviceFee;
    }

    private String generateOrderNumber() {
        return "ORD" + System.currentTimeMillis();
    }
}