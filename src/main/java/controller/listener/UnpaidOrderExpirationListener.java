package controller.listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import service.UnpaidOrderExpirationScheduler;

@WebListener
public class UnpaidOrderExpirationListener implements ServletContextListener {
    private UnpaidOrderExpirationScheduler scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = new UnpaidOrderExpirationScheduler();
        scheduler.start();
        System.out.println("[UnpaidOrderExpiration] Scheduler started.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.stop();
            System.out.println("[UnpaidOrderExpiration] Scheduler stopped.");
        }
    }
}
