import groovy.transform.Field

@Field
def do_build = "false"

@Library('prod-sec-libs') _1

pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr:'8'))
        ansiColor('xterm')
        disableConcurrentBuilds()
    }
    environment {
        DOCKER_BASE_IMAGE = 'cloudbees/plantuml-github-actions'
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
        /*
        stage('Check if build is needed') {
            steps {
                script {
                    do_build = sh(returnStdout: true, script: '''#!/bin/bash
                        set -x
                        git diff --name-only HEAD~1 HEAD |grep -q -E 'Dockerfile|VERSION|entrypoint|entrypoint-jx|Dockerfile-jx'
                        if [ "$?" -eq 0 ]; then
                            echo -n true
                        fi
                        '''
                    )
                    echo "do_build is now $do_build"
                    if (!do_build?.trim()) {
                        currentBuild.result = 'ABORTED'
                        error("No need to build. Aborting.")
                    }
                }
            }
        }
        */

        /*
        stage('Image info') {
            steps {
                script {
                    echo "Reading VERSION to establish semver"
                    def version = readFile('VERSION').trim()
                    def versions = version.split('\\.')
                    env.DOCKER_IMG_VERSION_MAJOR = versions[0]
                    env.DOCKER_IMG_VERSION_MINOR = versions[0] + '.' + versions[1]
                    env.DOCKER_IMG_VERSION_REV = versions[0] + '.' + versions[1] + '.' + versions[2]
                    env.DOCKER_IMG_VERSION_PATCH = version
                }
            }
        }
        */

        stage('Regular build') {
        when { equals expected: "true", actual: do_build }
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
        
        /*
        stage('Run Anchore') { 
            environment {
                ANCHORE_ACCOUNT = "security"
                ANCHORE_BAIL_ON_POLICY_FAIL = 1 // 0 true, 1 false
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    container(name: 'anchore', shell: '/bin/bash') {
                        script {
                            withCredentials([usernamePassword(credentialsId: 'anchore-g2-security', usernameVariable: 'ANCHORE_CLI_USER', passwordVariable: 'ANCHORE_CLI_PASS')]) {
                                anchoreHelper.submitAnchoreAnalysis()
                            }
                        }
                    }
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: '*.json', fingerprint: true

                    script {
                        withCredentials([string(credentialsId: 'defectdojo-srv-g2-prodsec', variable: 'ddApiToken')]) {
                            engagementId = defectDojo.getEngagementId('Whitesource docker image', 'Whitesource - Anchore run', env.ddApiToken, env.DOCKER_IMG_VERSION_PATCH)
                            if (engagementId) {
                                echo "Uploading to DefectDojo engagementId $engagementId..."
                                testId = defectDojo.uploadScan_Anchore('anchore-cli-image-vuln.json', engagementId, env.ddApiToken)
                                echo "Test ID is $testId."
                            } else {
                                echo "Could not retrieve a valid engagement ID. Upload aborted."
                                currentBuild.result = 'FAILURE'
                            }
                        }
                    }
                }
            }
        }
        */
    }

    post {
        success { 
            script { 
                def message = "${currentBuild.result}: Whitesource-agent version ${env.DOCKER_REPO_NAME}/${env.DOCKER_BASE_IMAGE}:${env.DOCKER_IMG_VERSION_PATCH} built and pushed. (`${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL})"
                slackSend (
                    channel: "${env.SLACK_CHANNELS}",
                    message: "${message}"
                )
            }
        }

        failure {
            script {
                def message = "${currentBuild.result}: Whitesource-agent version ${env.DOCKER_REPO_NAME}/${env.DOCKER_BASE_IMAGE}:${env.DOCKER_IMG_VERSION_PATCH} failed to build. (`${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL})"
                slackSend (
                    channel: "${env.SLACK_CHANNELS}",
                    message: "${message}"
                )
            }
        }
    }
}

