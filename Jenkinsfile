pipeline{
    agent any

    environment {
        IMAGE_NAME = "manojkrishnappa/genai:${GIT_COMMIT}"
        AWS_REGION = "ap-northeast-1"
        CLUSTER_NAME = "opskillup"
        NAMESPACE = "genai"
    }

    stages{
        stage('GitCheckout'){
            steps{
                git branch: 'genai', url: 'https://github.com/manojkrishnappa/Opskillsup.git'
            }
        }

        stage('Build Docker Image'){
            steps{
                sh '''
                docker build -t ${IMAGE_NAME} .
                '''
            }
        }

        stage('Push Docker Image'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'dockerhub-id', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh '''
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    docker push ${IMAGE_NAME}
                    '''
                }
            }
        }

        stage('update-kubeconfig'){
            steps{
                sh '''
                aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
                '''
            }
        }

        stage('Deploy to Kubernetes'){
            steps{
                withKubeCredentials(kubectlCredentials: [[caCertificate: '', clusterName: 'opskillup', contextName: '', credentialsId: 'kube', namespace: 'genai', serverUrl: 'https://6157A134C8100C4FCC2B7AF44399AC7D.gr7.ap-northeast-1.eks.amazonaws.com']]) {
                    sh '''
                    sed -i "s|replace|${IMAGE_NAME}|g" Deployment.yaml
                    kubectl apply -f Deployment.yaml -n ${NAMESPACE}
                    '''
                }
            }
        }
    }
}