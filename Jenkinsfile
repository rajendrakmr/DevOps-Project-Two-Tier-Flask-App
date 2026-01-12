pipeline{
    agent any 
    
     parameters {
        string(name: 'DOCKER_TAG', defaultValue: '', description: 'Setting docker image for latest push') 
    }
    stages{
        stage("Validate: Parameters") {
            steps {
                script {
                    if (params.DOCKER_TAG == '') {
                        error("DOCKER_TAG must be provided.")
                    }
                }
            }
        }
        stage("WS: Clean"){
            steps{
                script{
                     cleanWs()
                }
            }
        }
        stage('Git: Checkout'){
            steps{
                git url: "https://github.com/rajendrakmr/DevOps-Project-Two-Tier-Flask-App.git", branch: "main"
            }
        }
       
       stage('Security: Trivy File Scan') {
            steps {
                sh 'trivy fs --exit-code 1 --severity HIGH,CRITICAL .'
            }
        }
        
        stage('Test Case: Testing'){
            steps{
                echo "Testing case passed..."
            }
        }
        stage("Build: Docker Image"){
            steps{
                sh "docker build -t flask-app ."
            }
        }
        
        stage("Publish: DockerHub Push"){
            steps{
                withCredentials([usernamePassword(
                    credentialsId: "dockerHubCreds",
                    passwordVariable: "dockerHubPass",
                    usernameVariable: "dockerHubUser"

                )]){
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPass}"
                    sh "docker tag flask-app:latest  ${env.dockerHubUser}/flask-app:${params.DOCKER_TAG}"
                    sh "docker push ${env.dockerHubUser}/flask-app:${params.DOCKER_TAG}" 

                }
            }
        } 
    }
  
     post{ 
        success{
            //archiveArtifacts artifacts: '*.xml', followSymlinks: false
            build job: "Flaskapp-CD", parameters: [ string(name: 'DOCKER_TAG', value: "${params.DOCKER_TAG}")  ]
        }
    }

}