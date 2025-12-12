FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy server code
COPY main.py .

# Expose port
EXPOSE 8000

# Run the server
CMD ["python", "main.py"]
