pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '4d24f802-8dec-4401-a1a0-4b965cbc9f86'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        apikey = credentials('postman-token')
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
                    echo "Hello with docker"
                    pwd
                    ls -la
                '''
            }
        }
        stage('Test API') {
            agent{
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    test -f build/index.html
                    echo "Run collection -> Reqres - REST API basic CRUD"
                    npm install newman
                    node_modules/.bin/newman --version
                    node_modules/.bin/newman run "https://api.getpostman.com/collections/2506820-3cc8834e-0344-4217-8a5f-209de287b5eb?apikey=${apikey}" "\"  -e "https://api.getpostman.com/environments/2506820-66734cba-0764-4875-b92f-7eb8a6d12c12?apikey=${apikey}"
                '''
            }
        }
        // stage('Test API mock') {
        //     agent{
        //         docker {
        //             image 'node:18-alpine'
        //             reuseNode true
        //         }
        //     }
        //     steps {
        //         sh '''
        //             test -f build/index.html
        //             echo "Run collection -> Place order mockoon"
        //             npm install newman
        //             node_modules/.bin/newman --version
        //             node_modules/.bin/newman run "https://api.getpostman.com/collections/2506820-6af30d83-4cdd-4beb-a23b-552de05e731b?apikey=${apikey}" "\"  -e "https://api.getpostman.com/environments/2506820-78a4fa7a-2c40-4b01-919c-8d827e09a472?apikey=${apikey}"
        //         '''
        //     }
        // }
        stage('Run UI Tests') {
            steps {
                echo 'Cleaning workspace…'
                sh 'rm -rf Python_Selenium_Framework'

                echo 'Cloning repo…'
                git branch: 'master',
                    url:    'https://github.com/shovalsolo/Python_Selenium_Framework.git'

                echo 'Launching container for pytest…'
                sh 'docker run --rm -v "$WORKSPACE":/app selenium-pytest'
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
