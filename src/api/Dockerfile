# Use the official Python base image
FROM python:3.11-slim AS base

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file to the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

FROM base AS runtime
# Copy the rest of the application code to the container
COPY *.py .

# Expose the port that the FastAPI app will run on
EXPOSE 80

# Start the FastAPI app
#CMD ["fastapi", "dev", "main.py"]
#CMD ["python", "main.py"]
CMD ["fastapi", "run", "main.py", "--port", "80"]