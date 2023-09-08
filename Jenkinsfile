pipeline {
    agent any

    environment {
        registry = "weronikadocker/agile-ninjas-project"
        registryCredentials = "w-docker-credentials"
        dockerImage = "" // You can add a description here if needed
        MYSQL_DATABASE_DB = "test"
        MYSQL_DATABASE_PASSWORD = "test"
        MYSQL_DATABASE_USER = "test"
        MYSQL_DATABASE_HOST = "test"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/WeraGitHub/AgileNinjasProject.git' // Checkout the main branch of the Git repository
            }
        }
        stage('Build Docker image') {
            steps {
                script {
                    dockerImage = docker.build(registry) // Build Docker image and assign to dockerImage variable
                }
            }
        }
        stage('Test') {
            steps {
                withPythonEnv('python3') { // Use the pyenv pipeline plugin
                    sh 'pip install --no-cache-dir -r requirements.txt' // Install Python dependencies
                    sh 'python -m pytest tests/' // Run pytest for tests
                }
            }
        }
        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('', registryCredentials) { // Use the cloudbees plugin
                        dockerImage.push("${env.BUILD_NUMBER}") // Push the image with the build number as a tag
                        dockerImage.push("latest") // Push the image with "latest" tag
                    }
                }
            }
        }
        stage('Clean up') {
            steps {
                script {
                    sh 'docker image prune --all --force --filter "until=48h"' // Clean up Docker images older than 48 hours
                }
            }
        }
        stage('Refresh ASG') {
            steps {
                script {
                    withAWS(credentials: 'aws-qa-credentials', region: 'eu-west-2') { // Use the AWS pipleline plugin
                        def awsRegion = 'eu-west-2'
                        def autoScalingGroupName = 'AgileNinjas-ASG'

                        // Run the AWS CLI command to start the instance refresh
                        def cmd = "aws autoscaling start-instance-refresh --region ${awsRegion} --auto-scaling-group-name ${autoScalingGroupName}"

                        // Execute the command
                        def result = sh(script: cmd, returnStatus: true)

                        if (result == 0) {
                            echo "Instance refresh started successfully."
                        } else {
                            error "Failed to start instance refresh. Exit code: ${result}"
                        }
                    }
                }
            }
        }
    }
}
