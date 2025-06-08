pipeline {
    agent any

    environment {
        ENV_FILE = "${WORKSPACE}/.env"
        APPS_DIR = "${WORKSPACE}/apps"
        BASE_BRANCH = "origin/main"  // Adjust if needed
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Changed Apps') {
            steps {
                script {
                    def changedApps = sh(
                        script: "git diff --name-only ${BASE_BRANCH}...HEAD | grep '^apps/' | cut -d/ -f2 | sort -u",
                        returnStdout: true
                    ).trim().split('\n')

                    if (!changedApps[0]) {
                        echo "No changed apps found. Skipping deployment."
                        currentBuild.result = 'SUCCESS'
                        return
                    }

                    env.DEPLOY_APPS = changedApps.join(',')
                    echo "Changed apps to deploy: ${env.DEPLOY_APPS}"
                }
            }
        }

        stage('Deploy Changed Apps') {
            when {
                expression { env.DEPLOY_APPS }
            }
            steps {
                script {
                    def appList = env.DEPLOY_APPS.split(',')

                    appList.each { app ->
                        def appPath = "${APPS_DIR}/${app}"
                        def composeFile = "${appPath}/docker-compose.yml"

                        echo "🚀 Redeploying app: ${app}"

                        sh """
                            docker compose --env-file ${ENV_FILE} -f ${composeFile} down --remove-orphans
                            docker compose --env-file ${ENV_FILE} -f ${composeFile} pull
                            docker compose --env-file ${ENV_FILE} -f ${composeFile} up -d
                        """
                    }
                }
            }
        }

        stage('Cleanup Docker System (optional)') {
            steps {
                echo "🧹 Cleaning up unused Docker containers/images/networks/volumes"
                sh '''
                    docker container prune -f
                    docker image prune -af
                    docker volume prune -f
                    docker network prune -f
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully.'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
