pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '4d24f802-8dec-4401-a1a0-4b965cbc9f86'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {
        stage('Build') {
            agent{
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    pwd
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    echo "Hello with docker"
                    pwd
                    ls -la
                '''
            }
        }
        stage('Test') {
            agent{
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    test -f build/index.html
                    echo "Hello Test stage"
                    npm test
                '''
            }
        }
        stage('Deploy') {
            agent{
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
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
    post {
        always {
            junit 'test-results/junit.xml'
            echo "Cleaning up..."
        }
    }
}
