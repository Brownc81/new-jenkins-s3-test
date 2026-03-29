pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        AWS_DEFAULT_REGION  = 'us-east-1'
        TF_IN_AUTOMATION    = 'true'
        TF_PLUGIN_CACHE_DIR = '/var/lib/jenkins/.terraform.d/plugin-cache'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: '400398151894'
                ]]) {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: '400398151894'
                ]]) {
                    sh '''
                        terraform plan -out=tfplan
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Optional Destroy') {
            when {
                expression { return params.DESTROY == 'yes' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: '400398151894'
                ]]) {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }

    parameters {
        choice(
            name: 'DESTROY',
            choices: ['no', 'yes'],
            description: 'Set to yes to destroy resources'
        )
    }
}