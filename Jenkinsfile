pipeline {
    agent any

    environment {
        // No AWS_CREDS variable needed!
        AWS_DEFAULT_REGION = 'us-east-1'
        WORKING_DIR = 'Infra-demo/Dev'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
stage('Terraform Plan') {
    steps {
        dir("${env.WORKING_DIR}") {
            // We save the plan to a file called 'tfplan'
            sh 'terraform init'
            sh 'terraform plan -out=tfplan'
        }
    }
}

stage('Approval') {
    steps {
        // This creates the "Paused" state in the Jenkins UI with buttons
        input message: "Review the plan in the logs. Do you want to apply these changes to AWS?", 
              ok: "Deploy to Dev"
    }
}

stage('Terraform Apply') {
    steps {
        dir("${env.WORKING_DIR}") {
            // We apply the EXACT file we created in the plan stage
            sh 'terraform apply -auto-approve tfplan'
        }
    }
}
    }
}