# =====================================================
# Stage 1: BUILD - Dùng Gradle để build file WAR
# =====================================================
FROM gradle:8.7-jdk21 AS builder

WORKDIR /app

# Copy file cấu hình Gradle trước để tận dụng layer cache
COPY build.gradle settings.gradle ./

# Download dependencies trước (layer cache tối ưu)
RUN gradle dependencies --no-daemon 2>/dev/null || true

# Copy toàn bộ source code
COPY src ./src

# Build WAR (bỏ qua tests vì dự án Jakarta EE thuần không có unit test chuẩn)
RUN gradle clean war --no-daemon -x test

# =====================================================
# Stage 2: RUNTIME - Tomcat 10 + Java 21
# =====================================================
FROM tomcat:10.1-jdk21-temurin

LABEL maintainer="moc-tra-ecommerce"
LABEL description="Mộc Trà E-Commerce - Jakarta EE on Tomcat 10"

# Xóa ứng dụng mặc định của Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR từ stage builder
COPY --from=builder /app/build/libs/ROOT.war /usr/local/tomcat/webapps/ROOT.war

# Cấu hình JVM tối ưu cho production
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 \
               -Djava.security.egd=file:/dev/./urandom \
               -Dfile.encoding=UTF-8 \
               -Duser.timezone=Asia/Ho_Chi_Minh"

# Tomcat chạy trên port 8080
EXPOSE 8080

CMD ["catalina.sh", "run"]
