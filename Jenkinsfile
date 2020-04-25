pipeline {
  agent any
  stages {
    stage('Lint HTML') {
      steps {
        sh 'tidy -q -e *.html'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          app = docker.build(DOCKER_IMAGE_NAME)
          app.inside {
            sh 'echo Hello, Nginx!'
          }
        }

      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
          }
        }

      }
    }

    stage('Deploy blue & Green container') {
      steps {
        sshagent(credentials: ['Project']) {
          sh 'scp -o StrictHostKeyChecking=no  blue-controller.yaml green-controller.yaml blue-service.yaml  ubuntu@ip-172-31-26-144:/home/ubuntu/'
          script {
            try{
              sh "ssh ubuntu@ip-172-31-26-144 sudo kubectl apply -f ."
            }catch(error){
              sh "ssh ubuntu@ip-172-31-26-144 sudo kubectl create -f ."
            }
          }

        }

      }
    }

    stage('Wait user approve') {
      steps {
        input 'Ready to redirect traffic to green?'
      }
    }

    stage('Create the service in the cluster, redirect to green') {
      steps {
        sshagent(credentials: ['Project']) {
          sh 'scp -o StrictHostKeyChecking=no green-service.yaml ubuntu@ip-172-31-26-144:/home/ubuntu/run/'
          script {
            try{
              sh "ssh ubuntu@ip-172-31-26-144 sudo kubectl apply -f ."
            }catch(error){
              sh "ssh ubuntu@ip-172-31-26-144 sudo kubectl create -f ."
            }
          }

        }

      }
    }

  }
  environment {
    DOCKER_IMAGE_NAME = 'medhat16/capstoneimage'
  }
}
