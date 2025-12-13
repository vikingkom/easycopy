FROM node:18-slim AS webapp-builder

WORKDIR /webapp

# Copy webapp files
COPY webapp/package.json webapp/package-lock.json* ./
RUN npm install

COPY webapp/ ./
RUN npm run build

# Final stage
FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy server code
COPY main.py .

# Copy built webapp from builder stage
COPY --from=webapp-builder /webapp/dist ./static

# Expose port
EXPOSE 8000

# Run the server
CMD ["python", "main.py"]
