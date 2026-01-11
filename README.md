 
## End-to-End 2-Tier Flask Application Deployment using DevSecOps on AWS EKS


**Author:** Rajendra



## Tech stack used in this project:
- GitHub (Code)
- Docker (Containerization)
- Jenkins (CI)
- OWASP (Dependency check)
- SonarQube (Quality)
- Trivy (Filesystem Scan)
- ArgoCD (CD)
- AWS EKS (Kubernetes)
- Helm (Monitoring using grafana and prometheus)

---
#
> [!Note]
> This project will be implemented on Eurup Ireland region (eu-west-1).
> <b>Create 1 Master machine on AWS (t2.large) and 29 GB of storage.</b>

- <b>Open the below ports in security group</b>
![image](https://github.com/user-attachments/assets/4e5ecd37-fe2e-4e4b-a6ba-14c7b62715a3)


### Steps to deploy:

- <b id="EKS">Create EKS Cluster on AWS</b>
- IAM user with **access keys and secret access keys**

- AWSCLI should be configured (<a href="https://github.com/rajendrakmr/devops-installation-tools/blob/main/awscli.sh">Setup AWSCLI</a>)
  ```bash
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  sudo apt install unzip
  unzip awscliv2.zip
  sudo ./aws/install
  aws configure
  ```

- Install **kubectl**(<a href="https://github.com/rajendrakmr/devops-installation-tools/edit/main/kubectl.sh">Setup kubectl </a>)
  ```bash
  curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin
  kubectl version --short --client
  ```

- Install **eksctl**(<a href="https://github.com/rajendrakmr/devops-installation-tools/blob/main/eksctl.sh">Setup eksctl</a>)
  ```bash
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin
  eksctl version
  ```
- <b>Create EKS Cluster</b>
  ```bash
  eksctl create cluster --name=flaskapp --region=eu-west-1  --version=1.34 --without-nodegroup

  ```
- <b>Associate IAM OIDC Provider</b>
  ```bash
  eksctl utils associate-iam-oidc-provider --region=eu-west-1 --cluster=flaskapp --approve

  ```
> [!Note]
>  Make sure the before run nodegroup script ssh-public-key "eks-nodegroup-key is available in your aws account"
- <b>Create Nodegroup</b>
  ```bash
  eksctl create nodegroup --cluster=flaskapp \
                       --region=eu-west-1 \
                       --name=flaskapp \
                       --node-type=t2.medium \
                       --nodes=2 \
                       --nodes-min=2 \
                       --nodes-max=2 \
                       --node-volume-size=25 \
                       --ssh-access \
                       --ssh-public-key=eks-nodegroup-key 
  ```

- <b>Install Jenkins</b>
    ```bash
    sudo apt update -y
    sudo apt install fontconfig openjdk-21-jre -y

    sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update
    sudo apt install jenkins -y 

    ```
- After installing Jenkins, change the default port of jenkins from 8080 to 8081. Because our bankapp application will be running on 8080.
  - Open /usr/lib/systemd/system/jenkins.service file and change JENKINS_PORT environment variable 
![image](https://github.com/user-attachments/assets/6320ae49-82d4-4ae3-9811-bd6f06778483)
  - Reload daemon & Restart Jenkins
  ```bash
    sudo systemctl daemon-reload 
    sudo systemctl restart jenkins
  ```
#

- <b id="docker">Install docker</b>

    ```bash
    sudo apt install docker.io -y
    sudo usermod -aG docker $USER  && newgrp docker

    ```
- <b id="Sonar">Install and configure SonarQube</b>
    ```bash
    docker run -itd --name SonarQube-Server -p 9000:9000 sonarqube:lts-community 
 
    ```
- <b id="Sonars">With Volume configure SonarQube</b>
    ```bash 
    docker run -d \
    --name sonarqube-server \
    -p 9000:9000 \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_logs:/opt/sonarqube/logs \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    sonarqube:lts-community

    
    ```
#
- <b id="Trivy">Install Trivy</b>
    ```bash
    sudo apt-get install wget apt-transport-https gnupg lsb-release -y
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update -y
    sudo apt-get install trivy -y
    ```
#
 
- <b id="Argo">Install and Configure ArgoCD</b>
  - <b>Create argocd namespace</b>
  ```bash
  kubectl create namespace argocd

  ```
  - <b>Apply argocd manifest</b>
  ```bash
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

  ```
  - <b>Make sure all pods are running in argocd namespace</b>
  ```bash
  watch kubectl get pods -n argocd
  ```
  - <b>Install argocd CLI</b>
  ```bash
  curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.7/argocd-linux-amd64
  ```
  - <b>Provide executable permission</b>
  ```bash
  chmod +x /usr/local/bin/argocd
  ```
  - <b>Check argocd services</b>
  ```bash
  kubectl get svc -n argocd
  ```
  - <b>Change argocd server's service from ClusterIP to NodePort</b>
  ```bash
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
  ```
  - <b>Confirm service is patched or not</b>
  ```bash
  kubectl get svc -n argocd
  ```
  - <b> Check the port where ArgoCD server is running and expose it on security groups of a k8s worker node</b>
  ![image](https://github.com/user-attachments/assets/a2932e03-ebc7-42a6-9132-82638152197f)
  - <b>Access it on browser, click on advance and proceed with</b>
  ```bash
  <public-ip-worker>:<port>
  ```



#
## Clean Up
- <b id="Clean">Delete EKS cluster</b>
    ```bash
    eksctl delete cluster --name=flaskapp --region=eu-west-1

    ```

# 