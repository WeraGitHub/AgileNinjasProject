# syntax=docker/dockerfile:1
# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory to /app.
WORKDIR /app

# Copy only the requirements file initially, to leverage Docker cache
COPY requirements.txt requirements.txt

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Run app.py when the container launches
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
