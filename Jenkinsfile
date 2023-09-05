pipeline {
    agent any

    environment {
        registry = "weronikadocker/agile-ninjas-project"
        registryCredentials = "3a52191a-43d2-4c5f-a012-ab491169cc48"
        dockerImage = ""
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/WeraGitHub/AgileNinjasProject.git'
            }
        }
        stage('Build') {
            steps {
                script {
                    dockerImage = docker.build(registry)
                }
            }
        }
        stage('Test') {
            steps {
                echo 'test placeholder'
                // withPythonEnv('python3') {
                //     sh 'pip install pytest'
                //     sh 'pip install flask'
                //     sh 'pip install requests'
                //     sh 'python -m pytest tests/'
                // }
            }
        }
        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('', registryCredentials) {
                        dockerImage.push("${env.BUILD_NUMBER}")
                        dockerImage.push("latest")
                    }
                }
            }
        }
        stage('Clean up') {
            steps {
                script {
                    sh 'docker image prune --all --force --filter "until=48h"'
                }
            }
        }
        stage('Refresh ASG') {
            steps {
                script {
                    withAWS(credentials: 'aws-qa-credentials', region: 'eu-west-2') {
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