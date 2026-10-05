FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN pip install uv==0.1.10

RUN uv venv /app/.venv

ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

COPY requirements.txt .

RUN uv pip install -r requirements.txt


FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ENV PATH="/app/.venv/bin:$PATH"

WORKDIR /app

RUN useradd -m appuser

COPY --from=builder /app/.venv /app/.venv

COPY src/ /app/src/
COPY data/ /app/data/

RUN mkdir -p /app/artifacts && chown -R appuser:appuser /app

USER appuser

CMD ["python", "src/train.py"]