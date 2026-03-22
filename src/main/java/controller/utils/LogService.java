package controller.utils;

import java.util.logging.Level;
import java.util.logging.Logger;

public class LogService {
    private static final Logger LOGGER = Logger.getLogger("SecurityLog");
    public static void logWarning(String message) {
        LOGGER.log(Level.WARNING, "[SECURITY WARNING] " + message);
    }
    public static void logInfo(String message) {
        LOGGER.log(Level.INFO, "[INFO] " + message);
    }
    public static void logError(String message, Throwable throwable) {
        LOGGER.log(Level.SEVERE, "[ERROR] " + message, throwable);
    }
}
