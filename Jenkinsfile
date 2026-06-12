pipeline {
    agent any

    environment {
        DOCKER_IMAGE      = "naveen152005/myapp"
        SONAR_PROJECT_KEY = "jenkins-cicd-pipeline"
        SONAR_HOST_URL    = "http://localhost:9000"
        STAGING_SERVER_IP = "3.213.252.204"
        PROD_SERVER_IP    = "34.194.214.144"
        DEPLOY_USER       = "ec2-user"
        APP_PORT          = "3000"
        CONTAINER_NAME    = "cicd-app"
        PREVIOUS_BUILD    = "${BUILD_NUMBER.toInteger() - 1}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out branch: ${env.BRANCH_NAME}"
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm run test:coverage'
            }
            post {
                always {
                    junit 'coverage/junit.xml'
                    publishHTML(target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'coverage/lcov-report',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report'
                    ])
                }
            }
        }

        stage('SonarQube Scan') {
            when {
                anyOf {
                    branch 'staging'
                    branch 'main'
                }
            }
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh """
                        npx sonar-scanner \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.host.url=${SONAR_HOST_URL} \
                          -Dsonar.login=${SONAR_AUTH_TOKEN}
                    """
                }
            }
        }

        stage('Quality Gate') {
            when {
                anyOf {
                    branch 'staging'
                    branch 'main'
                }
            }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Push') {
            when {
                anyOf {
                    branch 'staging'
                    branch 'main'
                }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKER_HUB_CREDENTIALS',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} -t ${DOCKER_IMAGE}:latest .
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest
                        docker logout
                    """
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'staging'
            }
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'SSH_KEY',
                    keyFileVariable: 'SSH_PRIVATE_KEY'
                )]) {
                    sh """
                        chmod +x scripts/deploy.sh
                        SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY} \
                        DEPLOY_USER=${DEPLOY_USER} \
                        SERVER_IP=${STAGING_SERVER_IP} \
                        DOCKER_IMAGE=${DOCKER_IMAGE} \
                        BUILD_NUMBER=${BUILD_NUMBER} \
                        CONTAINER_NAME=${CONTAINER_NAME} \
                        APP_PORT=${APP_PORT} \
                        bash scripts/deploy.sh
                    """
                }
            }
        }

        stage('Health Check - Staging') {
            when {
                branch 'staging'
            }
            steps {
                sh """
                    chmod +x scripts/health-check.sh
                    SERVER_IP=${STAGING_SERVER_IP} APP_PORT=${APP_PORT} bash scripts/health-check.sh
                """
            }
        }

        stage('Manual Approval - Production') {
            when {
                branch 'main'
            }
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: "Deploy build #${BUILD_NUMBER} to PRODUCTION?",
                          ok: 'Yes, deploy to production',
                          submitter: 'admin'
                }
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'SSH_KEY',
                    keyFileVariable: 'SSH_PRIVATE_KEY'
                )]) {
                    sh """
                        chmod +x scripts/deploy.sh
                        SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY} \
                        DEPLOY_USER=${DEPLOY_USER} \
                        SERVER_IP=${PROD_SERVER_IP} \
                        DOCKER_IMAGE=${DOCKER_IMAGE} \
                        BUILD_NUMBER=${BUILD_NUMBER} \
                        CONTAINER_NAME=${CONTAINER_NAME} \
                        APP_PORT=${APP_PORT} \
                        bash scripts/deploy.sh
                    """
                }
            }
        }

        stage('Health Check - Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def healthCheckResult = sh(
                        script: """
                            chmod +x scripts/health-check.sh
                            SERVER_IP=${PROD_SERVER_IP} APP_PORT=${APP_PORT} bash scripts/health-check.sh
                        """,
                        returnStatus: true
                    )
                    if (healthCheckResult != 0) {
                        echo "Health check failed! Triggering rollback..."
                        withCredentials([sshUserPrivateKey(
                            credentialsId: 'SSH_KEY',
                            keyFileVariable: 'SSH_PRIVATE_KEY'
                        )]) {
                            sh """
                                chmod +x scripts/rollback.sh
                                SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY} \
                                DEPLOY_USER=${DEPLOY_USER} \
                                SERVER_IP=${PROD_SERVER_IP} \
                                DOCKER_IMAGE=${DOCKER_IMAGE} \
                                PREVIOUS_BUILD_NUMBER=${PREVIOUS_BUILD} \
                                CONTAINER_NAME=${CONTAINER_NAME} \
                                APP_PORT=${APP_PORT} \
                                bash scripts/rollback.sh
                            """
                        }
                        error("Production health check failed. Rollback executed.")
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                def branch = env.BRANCH_NAME
                def msg = "BUILD SUCCESS | Branch: ${branch} | Job: ${env.JOB_NAME} | Build: #${env.BUILD_NUMBER} | ${env.BUILD_URL}"
                withCredentials([string(credentialsId: 'SLACK_WEBHOOK', variable: 'SLACK_URL')]) {
                    sh """
                        curl -s -X POST -H 'Content-type: application/json' \
                        --data '{"text":"SUCCESS: ${msg}"}' \
                        "${SLACK_URL}"
                    """
                }
            }
        }
        failure {
            script {
                def branch = env.BRANCH_NAME
                def msg = "BUILD FAILED | Branch: ${branch} | Job: ${env.JOB_NAME} | Build: #${env.BUILD_NUMBER} | ${env.BUILD_URL}"
                withCredentials([string(credentialsId: 'SLACK_WEBHOOK', variable: 'SLACK_URL')]) {
                    sh """
                        curl -s -X POST -H 'Content-type: application/json' \
                        --data '{"text":"FAILED: ${msg}"}' \
                        "${SLACK_URL}"
                    """
                }
            }
        }
        always {
            echo "Pipeline completed for branch: ${env.BRANCH_NAME}"
            cleanWs()
        }
    }
}
