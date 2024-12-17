pipeline {
    agent any

    environment {
        // Set the AWS region and the key pair name for EC2 instances
        AWS_REGION = 'us-east-1'
        KEY_NAME = 'ansible'
        TERRAFORM_DIR = 'terraform' // Adjust to your Terraform directory
        ANSIBLE_PLAYBOOK = 'ansible/playbook.yml' // Adjust to your playbook path
        INVENTORY_FILE = 'ansible/inventory.ini' // Adjust to your inventory path
    }

    stages {
        stage('Clone GitHub Repository') {
            steps {
                // Checkout the repository
                git 'https://github.com/your-repo.git' // Replace with your GitHub repository URL
            }
        }

        stage('Initialize Terraform') {
            steps {
                script {
                    // Navigate to the Terraform directory
                    dir(TERRAFORM_DIR) {
                        // Initialize Terraform (downloads necessary providers and modules)
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Apply the Terraform configuration to create EC2 instances
                    dir(TERRAFORM_DIR) {
                        // Plan and Apply Terraform
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage('Create Ansible Dynamic Inventory') {
            steps {
                script {
                    // Create dynamic inventory for Ansible using Terraform output
                    dir(TERRAFORM_DIR) {
                        // Get the public IP addresses of the EC2 instances and write to inventory file
                        def frontend_ip = sh(script: "terraform output -raw frontend", returnStdout: true).trim()
                        def backend_ip = sh(script: "terraform output -raw backend", returnStdout: true).trim()

                        // Create the Ansible inventory file dynamically
                        writeFile file: INVENTORY_FILE, text: """
[frontend]
${frontend_ip}

[backend]
${backend_ip}
"""
                    }
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Run the Ansible playbook with dynamic inventory
                    sh "ansible-playbook -i ${INVENTORY_FILE} ${ANSIBLE_PLAYBOOK}"
                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    // Optional: Destroy the Terraform infrastructure after completion
                    dir(TERRAFORM_DIR) {
                        sh "terraform destroy -auto-approve"
                    }
                }
            }
        }
    }

    post {
        always {
            // Archive logs, output, etc.
            archiveArtifacts artifacts: '**/terraform.tfstate*', allowEmptyArchive: true
            junit '**/test-*.xml' // Optional if you have test results to archive
        }
        success {
            // Send success notification (optional)
            echo 'Deployment and Configuration Successful!'
        }
        failure {
            // Send failure notification (optional)
            echo 'Deployment or Configuration Failed!'
        }
    }
}
