# Use a lightweight Python image
FROM python:3.11-slim

# Install necessary system packages, including PostgreSQL
RUN apt-get update && apt-get install -y \
    git \
    uvicorn \
    postgresql postgresql-contrib \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set PostgreSQL environment variables
ENV POSTGRES_USER=video_user
ENV POSTGRES_PASSWORD=secure_password
ENV POSTGRES_DB=video_db
ENV PATH="/usr/lib/postgresql/15/bin:$PATH"

# Initialize PostgreSQL data directory using the full path to initdb
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql

# Switch to the postgres user
USER postgres

# Use the full path to initdb to initialize PostgreSQL
RUN initdb -D /var/lib/postgresql/data

# Create PostgreSQL user and database
RUN pg_ctl -D /var/lib/postgresql/data start && \
    psql --command "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';" && \
    psql --command "CREATE DATABASE $POSTGRES_DB OWNER $POSTGRES_USER;" && \
    pg_ctl -D /var/lib/postgresql/data stop

# Switch back to the root user to set up the application
USER root

# Create a new user for running the application
RUN useradd -m guard
USER guard
WORKDIR /home/guard/ai


# Clone the private GitHub repository
ARG GH_USER
ARG GH_TOKEN
ARG GH_REPO
RUN git clone https://${GH_TOKEN}@github.com/${GH_USER}/${GH_REPO}.git .

# Add the .local/bin to PATH
ENV PATH="/home/guard/.local/bin:$PATH"

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose only the app's port
EXPOSE 8000

# Start PostgreSQL and the app
USER postgres

CMD /usr/lib/postgresql/15/bin/pg_ctl -D /var/lib/postgresql/data start 

USER guard

CMD uvicorn app.main:app --host 0.0.0.0 --port 8000
