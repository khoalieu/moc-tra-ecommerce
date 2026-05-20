package service;

import dao.DAOFactory;
import dao.SystemLogDAO;
import model.SystemLog;

import java.util.List;

public class SystemLogService {

    private SystemLogDAO systemLogDAO;

    public SystemLogService() {
        this.systemLogDAO = DAOFactory.getInstance().getSystemLogDAO();
    }
    public void log(Integer userID, String action, String entityType, Integer entityID) {
        systemLogDAO.insertLog(userID, action, entityType, entityID);
    }

    public List<SystemLog> getAllLogs() {
        return systemLogDAO.getAllLogs();
    }
}