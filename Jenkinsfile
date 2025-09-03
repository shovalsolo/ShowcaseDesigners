pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '4d24f802-8dec-4401-a1a0-4b965cbc9f86'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {
        stage('Build') {
            agent any
            steps {
                sh '''
                    pwd
                    ls -la
                    npm install
                    npm --version
                    node install
                    node --version
                    echo "Hello with docker"
                    pwd
                    ls -la
                '''
            }
        }
        stage('Test') {
            agent any
            steps {
                sh '''
                    echo "Hello Test stage"
                '''
            }
        }
        stage('Deploy') {
            agent any
            steps {
                sh '''
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying with netlify production. Product site ID: ${NETLIFY_SITE_ID}"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --prod
                '''
            }
        }
    }
}
