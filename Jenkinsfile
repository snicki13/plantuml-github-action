pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr:'8'))
        ansiColor('xterm')
        disableConcurrentBuilds()
    }
    environment {
        DOCKER_BASE_IMAGE = 'cloudbees/plantuml-github-action'
        DOCKER_REPO_NAME = 'docker.io'
        SLACK_CHANNELS = "#notify-product-security"
    }

    agent {
        kubernetes {
            label "kaniko-${UUID.randomUUID().toString()}"
            yamlFile 'KubePod.yaml'
        }
    }
    stages {
        stage('Regular build') {
            environment {
              PATH = "/busybox:/kaniko:$PATH"
            }

            steps {
                container(name: 'kaniko', shell: '/busybox/sh') {
                    withCredentials([file(credentialsId: 'dockerhub-cbproductsecurity-PAT', variable: 'dockerconfig')]) {
                        sh '''
                            mkdir -p /kaniko/.docker
                            cp ${dockerconfig} /kaniko/.docker/config.json
                        '''
                    }

                    sh '''#!/busybox/sh
                        set -e
                        echo "docker image: $DOCKER_BASE_IMAGE"

                        /kaniko/executor --context `pwd` --dockerfile=`pwd`/Dockerfile --destination $DOCKER_REPO_NAME/$DOCKER_BASE_IMAGE:latest \
                    '''
                }
            }
        }
    }

    post {
        success { 
            script { 
                def message = "${currentBuild.result}: ${env.DOCKER_REPO_NAME}/${env.DOCKER_BASE_IMAGE} built and pushed. (`${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL})"
                slackSend (
                    channel: "${env.SLACK_CHANNELS}",
                    message: "${message}"
                )
            }
        }

        failure {
            script {
                def message = "${currentBuild.result}: ${env.DOCKER_REPO_NAME}/${env.DOCKER_BASE_IMAGE} (`${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL})"
                slackSend (
                    channel: "${env.SLACK_CHANNELS}",
                    message: "${message}"
                )
            }
        }
    }
}

