pipeline {
    agent any
    
    tools {
        dockerTool 'docker' 
    }
        
    stages {
        

        stage('prep') {
            steps {        
                git url: 'https://github.com/akolodkin/weekly-team-report-html.git', branch: 'develop-team-2'
            }
        }
        stage('nmp-build') {
            agent {
                docker {
                    image 'node:16'
                }
            }
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        
         stage('publish-to-s3 ') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    args "--entrypoint=''"
                }
            }
            steps {
                sh "ls -la"
                sh 'aws --version'
            }
        }

        // stage('terraform install and build') {
        //     steps {
        //         //sh "wget -O terraform_1.0.0_linux_amd64.zip https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip"
        //         //sh "unzip terraform_*_linux_amd64.zip -d /usr/local/bin"
        //         sh 'terraform init'
        //     // sh "terraform plan"
        //     //  sh "terraform apply --auto-approve"
        //     //
        //     }
        // }

        // stage('deploy to S3') {
        //     steps {
        //         //sh 'aws s3 cp --profile bill6600 . s3://bill-bucket-77 --recursive --acl public-read'
        //         sh 'aws s3 ls --profile bill6600'
        //     //
        //     }
        // }

        // stage('sonar-scanner') {
        //     steps {
        //         script {
        //             def SONARQUBE_HOSTNAME = 'sonarqube'
        //             def sonarqubeScannerHome = tool name: 'sonar', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
        //             withCredentials([string(credentialsId: 'sonar', variable: 'sonarLogin')]) {
        //                 sh "${sonarqubeScannerHome}/bin/sonar-scanner -e -Dsonar.host.url=http://${SONARQUBE_HOSTNAME}:9000 -Dsonar.login='admin' -Dsonar.password='Admin@123' -Dsonar.projectName=WebApp -Dsonar.projectVersion=${env.BUILD_NUMBER} -Dsonar.projectKey=GS -Dsonar.sources=src/ -Dsonar.java.binaries=build/**/*"
        //             }
        //         }
        //     }
        // }
    }
}
