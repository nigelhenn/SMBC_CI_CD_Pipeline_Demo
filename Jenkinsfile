pipeline {
  agent any

  environment {
    TF_VERSION = '1.6.0'
    TF_WORKSPACE = 'default'
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/nigelhenn/SMBC_CI_CD_Pipeline_Demo.git', branch: 'main'
      }
    }

    stage('Init') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Terraform']]) {
          sh 'terraform init'
        }
      }
    }

    stage('Validate') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Terraform']]) {
          sh 'terraform validate'
        }
      }
    }

    stage('Plan') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Terraform']]) {
          sh 'terraform plan -out=tfplan'
        }
      }
    }

    stage('Apply') {
      steps {
        input message: 'Approve Apply?'
        withCredentials([
          [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Terraform'],
          file(credentialsId: 'terraform-key', variable: 'TF_KEY')
        ]) {
          sh '''
            echo "Applying Terraform plan..."
            export TF_VAR_private_key_path=$TF_KEY
            terraform apply -auto-approve tfplan
          '''
        }
      }
    }

    stage('Inventory') {
      steps {
        withCredentials([
          file(credentialsId: 'terraform-key', variable: 'TF_KEY')
        ]) {
          sh 'terraform output -json > tf_output.json'
          script {
            def tfOutput = readJSON file: 'tf_output.json'
            def ips = tfOutput.web_instance_ips?.value ?: []
            def inventory = [
              all: [
                hosts: ips.collectEntries { ip -> [(ip): [ansible_user: "ec2-user"]] }
              ]
            ]
            writeFile file: 'inventory.yaml', text: groovy.json.JsonOutput.prettyPrint(groovy.json.JsonOutput.toJson(inventory))
          }
        }
      }
    }

    stage('Deploy') {
      steps {
        withCredentials([
          [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Terraform'],
          file(credentialsId: 'terraform-key', variable: 'TF_KEY')
        ]) {
          sh '''
            echo "Running Ansible playbook..."
            ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yaml -u ec2-user --private-key "$TF_KEY" playbook.yaml
          '''
        }
      }
    }

    stage('Health') {
      steps {
        script {
          def tfOutput = readJSON file: 'tf_output.json'
          def ips = tfOutput.web_instance_ips?.value ?: []

          if (ips.isEmpty()) {
            echo "No IPs found — skipping health check."
          } else {
            ips.each { ip ->
              echo "Checking ${ip} ..."
              def status = sh(
                script: "curl -s -o /dev/null -w '%{http_code}' http://${ip}",
                returnStdout: true
              ).trim()

              if (status == '200') {
                echo "✅ ${ip} healthy"
              } else {
                echo "❌ ${ip} failed"
                error("One or more instances failed health check.")
              }
            }
          }
        }
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
