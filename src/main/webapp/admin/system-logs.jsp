<%--
  Created by IntelliJ IDEA.
  User: Hi
  Date: 18/05/2026
  Time: 10:38 CH
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.SystemLog" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>System Logs</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin.css">

    <style>

        .logs-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }

        .logs-table th,
        .logs-table td {
            padding: 14px;
            border-bottom: 1px solid #eee;
            text-align: left;
        }

        .logs-table th {
            background: #f5f5f5;
            font-weight: 600;
        }

        .logs-table tr:hover {
            background: #fafafa;
        }

        .log-badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            background: #f0f0f0;
        }

    </style>

</head>

<body>

<div class="admin-container">

    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="system-logs"/>
    </jsp:include>

    <main class="admin-main">

        <header class="admin-header">
            <div class="header-left">
                <h1>System Logs</h1>
            </div>
        </header>

        <div class="admin-content">

            <table class="logs-table">

                <tr>
                    <th>LogID</th>
                    <th>UserID</th>
                    <th>Action</th>
                    <th>Entity Type</th>
                    <th>Entity ID</th>
                    <th>Timestamp</th>
                </tr>

                <%
                    List<SystemLog> logs =
                            (List<SystemLog>) request.getAttribute("logs");

                    if (logs != null) {

                        for (SystemLog log : logs) {
                %>

                <tr>

                    <td>
                        <%= log.getLogID() %>
                    </td>

                    <td>
                        <%= log.getUserID() %>
                    </td>

                    <td>
                        <%= log.getAction() %>
                    </td>

                    <td>
                        <span class="log-badge">
                            <%= log.getEntityType() %>
                        </span>
                    </td>

                    <td>
                        <%= log.getEntityID() %>
                    </td>

                    <td>
                        <%= log.getTimestamp() %>
                    </td>

                </tr>

                <%
                        }
                    }
                %>

            </table>

        </div>

    </main>

</div>

</body>
</html>