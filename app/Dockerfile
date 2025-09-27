FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt && useradd -m appuser

COPY src/ .

USER appuser

EXPOSE 8080

CMD ["python", "app.py"]
