package model.cart;

import model.product.Product;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

public class Cart {
    // Key: Product ID, Value: CartItem
    private Map<Integer, CartItem> items;

    public Cart() {
        items = new HashMap<>();
    }

    public void add(Product product, int quantity) {
        if (items.containsKey(product.getId())) {
            CartItem existingItem = items.get(product.getId());
            existingItem.setQuantity(existingItem.getQuantity() + quantity);
        } else {
            CartItem newItem = new CartItem(product, quantity);
            items.put(product.getId(), newItem);
        }
    }
    public void update(int productId, int quantity) {
        if (items.containsKey(productId)) {
            if (quantity <= 0) {
                items.remove(productId);
            } else {
                items.get(productId).setQuantity(quantity);
            }
        }
    }

    public void remove(int productId) {
        items.remove(productId);
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
    public void removeItems(String[] ids) {
        if (ids == null) return;
        for (String id : ids) {
            int productId = Integer.parseInt(id);
            if (items.containsKey(productId)) {
                CartItem item = items.get(productId);
                items.remove(productId);
            }
        }
    }
}