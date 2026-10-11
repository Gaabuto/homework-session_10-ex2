# Dockerfile Single-stage cho API Node.js/Express

## 1. Mục tiêu
Đóng gói ứng dụng REST API (Node.js/Express) thành Docker image bằng Dockerfile single-stage, build image `hw-backend:v1` và chạy container `app-single-stage`.

## 2. Cấu trúc dự án
- `package.json`: khai báo thư viện express và script chạy.
- `server.js`: API trả về JSON ở đường dẫn `/`.
- `Dockerfile`: các chỉ thị đóng gói ứng dụng.

## 3. Dockerfile
~~~dockerfile
# Use the lightweight Node.js 18 image based on Alpine Linux
FROM node:18-alpine
# Set the working directory inside the container
WORKDIR /app
# Set the port the app listens on
ENV PORT=3000
# Copy package.json (and package-lock.json if present) first to cache the dependency layer
COPY package*.json ./
# Install production dependencies only
RUN npm install --omit=dev
# Copy the application source code
COPY server.js ./
# Document that the container listens on port 3000
EXPOSE 3000
# Start the server when the container runs
CMD ["node", "server.js"]
~~~

- `FROM node:18-alpine`: image nền Node.js 18 bản Alpine nhẹ.
- `WORKDIR /app`: thư mục làm việc trong container.
- `ENV PORT=3000`: biến môi trường cổng mà ứng dụng lắng nghe.
- `COPY package*.json ./`: chép file khai báo thư viện trước để tận dụng cache của Docker.
- `RUN npm install --omit=dev`: cài thư viện cần để chạy.
- `COPY server.js ./`: chép mã nguồn.
- `EXPOSE 3000`: khai báo container dùng cổng 3000.
- `CMD ["node", "server.js"]`: lệnh khởi chạy dạng exec form, tiến trình nhận tín hiệu trực tiếp, không qua shell.

## 4. Các lệnh đã chạy
~~~bash
docker build -t hw-backend:v1 .
docker run -d --name app-single-stage -p 8085:3000 hw-backend:v1
docker ps
docker logs app-single-stage
curl -i http://localhost:8085/
~~~

- `-d`: chạy nền. `--name`: đặt tên container. `-p 8085:3000`: cổng máy chủ 8085 ánh xạ vào cổng 3000 trong container.

## 5. Kết quả
~~~text
# docker build -t hw-backend:v1 . (last 15 lines)
#9 [5/5] COPY server.js ./
#9 DONE 0.1s

#10 exporting to image
#10 exporting layers
#10 exporting layers 0.5s done
#10 exporting manifest sha256:0c6bfdbf196588175f1769ab78921d3343801203adb9c93f186958cf8e840a99
#10 exporting manifest sha256:0c6bfdbf196588175f1769ab78921d3343801203adb9c93f186958cf8e840a99 done
#10 exporting config sha256:c2ab081592f3b7a83fe3dacf6f72f86ef813ec52d824bedebd5fa4c89890953e done
#10 exporting attestation manifest sha256:bc0dc9e6ce8de1765924983b421e5cd4ab40b63b6419061e83aef02ff934207e 0.0s done
#10 exporting manifest list sha256:ea0b560a5e497473f3135c69e2deb682b7d03947fbc21b13d1f33f55c8c58a0e done
#10 naming to docker.io/library/hw-backend:v1 done
#10 unpacking to docker.io/library/hw-backend:v1
#10 unpacking to docker.io/library/hw-backend:v1 2.2s done
#10 DONE 2.8s
-----
# docker run -d --name app-single-stage -p 8085:3000 hw-backend:v1
-----
# docker ps --filter name=app-single-stage
CONTAINER ID   IMAGE           COMMAND                  CREATED          STATUS          PORTS                                         NAMES
7f002861772d   hw-backend:v1   "docker-entrypoint.s…"   25 seconds ago   Up 25 seconds   0.0.0.0:8085->3000/tcp, [::]:8085->3000/tcp   app-single-stage
-----
# docker logs app-single-stage
Server listening on port 3000
-----
# curl -i http://localhost:8085/
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 64
ETag: W/"40-upZb7Fps+hszzRU9BoKtiCsmGCQ"
Date: Sun, 11 Oct 2026 21:56:44 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"status":"success","message":"Hello from Docker Single-stage!"}
~~~

Image build thành công, container ở trạng thái Up, `curl` trả về HTTP 200 OK kèm JSON.

## 6. Ghi chú
- Single-stage nghĩa là image cuối vẫn giữ công cụ build (npm và cache) nên lớn hơn image multi-stage.
- VPS dùng chung cho 4 sinh viên, cổng 8080 và 8083 đã bị chiếm nên dùng cổng máy chủ 8085 thay cho 8080 (cổng trong container vẫn là 3000).
