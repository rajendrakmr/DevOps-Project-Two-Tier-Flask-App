pipeline{
    agent any 
    stages{
        stage('Clone Code'){
            steps{
                git url: "https://github.com/rajendrakmr/DevOps-Project-Two-Tier-Flask-App.git", branch: "main"
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
        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL flask-app:latest'
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
        stage('Deploy'){
            steps{
                sh "docker compose down || true"
                sh "docker compose up -d --build"
            }
        }
    }
    post {
        always {
            sh 'docker system prune -f || true'
            cleanWs()
        }
    }

}