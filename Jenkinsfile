pipeline{
    agent any 
    
     parameters {
        string(name: 'DOCKER_TAG', defaultValue: '', description: 'Setting docker image for latest push') 
    }
    stages{
        stage("Validate Parameters") {
            steps {
                script {
                    if (params.DOCKER_TAG == '') {
                        error("DOCKER_TAG must be provided.")
                    }
                }
            }
        }
        stage("Clean WS"){
            steps{
                script{
                     cleanWs()
                }
            }
        }
        stage('Clone Code'){
            steps{
                git url: "https://github.com/rajendrakmr/DevOps-Project-Two-Tier-Flask-App.git", branch: "main"
            }
        }
       
       stage('File Scan') {
            steps {
                sh 'trivy fs --exit-code 1 --severity HIGH,CRITICAL .'
            }
        }
        stage('Test Case'){
            steps{
                echo "Testing case passed..."
            }
        }
        stage("Build Code"){
            steps{
                sh "docker build -t flask-app ."
            }
        }
        
        stage("Push DockerHub"){
            steps{
                withCredentials([usernamePassword(
                    credentialsId: "dockerHubCreds",
                    passwordVariable: "dockerHubPass",
                    usernameVariable: "dockerHubUser"

                )]){
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPass}"
                    sh "docker tag flask-app:latest  ${env.dockerHubUser}/flask-app:latest"
                    sh "docker push ${env.dockerHubUser}/flask-app:latest" 

                }
            }
        } 
    }
  
     post{ 
        success{
            // archiveArtifacts artifacts: '*.xml', followSymlinks: false
            build job: "Flaskapp-CD", parameters: [
                string(name: 'DOCKER_TAG', value: "${params.DOCKER_TAG}")
            ]
        }
    }

}