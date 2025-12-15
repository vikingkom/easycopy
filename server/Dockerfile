FROM node:18-slim AS webapp-builder

WORKDIR /webapp



# Copy webapp files for build-time API URL
COPY server/webapp/package.json server/webapp/package-lock.json* ./
RUN npm install

COPY server/webapp/ ./
RUN npm run build

# Python backend stage
FROM python:3.11-slim AS backend

WORKDIR /app

# Copy requirements and install dependencies
COPY server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy server code
COPY server/main.py .

# Copy built webapp from builder stage
COPY --from=webapp-builder /webapp/dist ./static

# Expose port
EXPOSE 8000

# Run the server
CMD ["python", "main.py"]
