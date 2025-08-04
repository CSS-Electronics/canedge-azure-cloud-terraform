FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY test_container.py .
RUN chmod +x test_container.py

# Set Python to run in unbuffered mode to ensure logs are flushed immediately
ENV PYTHONUNBUFFERED=1

CMD ["python", "-u", "test_container.py"]
