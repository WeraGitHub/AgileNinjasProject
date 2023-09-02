# syntax=docker/dockerfile:1
# Use an official Python runtime as a parent image (not sure what's the difference between slim and slim-bullseye
FROM python:3.11-slim

# Set the working directory to /app. ⁠ (/app is more conventional name, but don't quote me on that)
WORKDIR /app

# Copy only the requirements file initially, to leverage Docker cache
COPY requirements.txt requirements.txt

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Set Flask environment to production
ENV FLASK_ENV=debug

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Run app.py when the container launches
CMD ["python", "app.py"]