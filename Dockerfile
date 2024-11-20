FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Build argument for GitHub credentials
ARG GITHUB_USER
ARG GITHUB_TOKEN

# Clone the private repository
RUN apt-get update && apt-get install -y git \
    && git clone https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/<username>/<private-repo>.git . \
    && apt-get remove -y git && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port
EXPOSE 8000

# Run FastAPI
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

