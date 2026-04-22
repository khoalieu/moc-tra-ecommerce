package model.cart;

import model.product.Product;
import model.product.ProductVariant;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Cart {
    private Map<Integer, CartItem> items;

    public Cart() {
        items = new HashMap<>();
    }

    public void add(Product product, ProductVariant variant, int quantity) {
        int key = variant.getId();

        if (items.containsKey(key)) {
            CartItem existingItem = items.get(key);
            existingItem.setQuantity(existingItem.getQuantity() + quantity);
        } else {
            CartItem newItem = new CartItem(product, variant, quantity);
            items.put(key, newItem);
        }
    }
    public void update(int variantId, int quantity) {
        if (items.containsKey(variantId)) {
            if (quantity <= 0) {
                items.remove(variantId);
            } else {
                items.get(variantId).setQuantity(quantity);
            }
        }
    }
    public void remove(int variantId) {
        items.remove(variantId);
    }

    public Collection<CartItem> getItems() {
        return items.values();
    }
    public double getTotalMoney() {
        double total = 0;
        for (CartItem item : items.values()) {
            total += item.getTotalPrice();
        }
        return total;
    }

    public int getTotalQuantity() {
        int count = 0;
        for (CartItem item : items.values()) {
            count += item.getQuantity();
        }
        return count;
    }
    public void removeItems(String[] variantIds) {
        if (variantIds == null) return;
        for (String id : variantIds) {
            try {
                int vId = Integer.parseInt(id);
                items.remove(vId);
            } catch (NumberFormatException e) {
            }
        }
    }

    public void clear() {
        items.clear();
    }
}