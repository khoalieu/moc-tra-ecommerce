package service;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class UnpaidOrderExpirationScheduler {
    private final ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor(r -> {
        Thread thread = new Thread(r, "unpaid-order-expiration");
        thread.setDaemon(true);
        return thread;
    });

    public void start() {
        executor.scheduleWithFixedDelay(this::runSafely, 1, 10, TimeUnit.MINUTES);
    }

    public void stop() {
        executor.shutdownNow();
    }

    private void runSafely() {
        try {
            new UnpaidOrderExpirationService().cancelExpiredUnpaidOnlineOrders();
        } catch (Exception e) {
            System.err.println("[UnpaidOrderExpiration] Failed to cancel expired unpaid orders: " + e.getMessage());
        }
    }
}
