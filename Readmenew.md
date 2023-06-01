# Flask Application Deployment on AWS ECS and ECR with Bash Script, Terraform, and Ansible

This repository contains the code and instructions for deploying a Flask application on AWS ECS (Elastic Container Service) and ECR (Elastic Container Registry) using bash scripts, Terraform, and Ansible.

## Prerequisites

- AWS Account
- AWS CLI
- Docker
- Terraform
- Ansible
- Bash Scirpting

## Setup

### AWS Resources

1. Create an AWS ECS cluster using the AWS Management Console or AWS CLI.
2. Create an AWS ECR repository to store your Docker images.
3. Set up IAM roles and permissions for ECS and ECR.

### Bash Script

1. Clone the repository and navigate to the project directory.
2. Make the `deploy.sh` file executable: `chmod +x bash_script.sh`.

### Terraform

1. Install Terraform on your local machine.
2. Open the `terraform` directory.
3. Run `terraform init` to initialize the Terraform configuration.

### Ansible

1. Install Ansible on your local machine.
2. Navigate to the project directory.
3. Modify the `inventory` file to specify the target hosts as aws with creditionals.
4. check the `playbook.yml` file to define the deployment tasks to run 2 yamls file which builds docker image and pushes the image to ECR and build ECS cluster on AWS.
5. Run the Ansible playbook: `ansible-playbook -i inventory playbook.yml` files one after the other.

## Deployment

1. Build the Docker image for your Flask application: `docker build -t <image-name> .`
2. Tag the Docker image: `docker tag <image-name> <ECR-repository-uri>:<tag>`
3. Push the Docker image to the ECR repository: `docker push <ECR-repository-uri>:<tag>`
4. Deploy the application to the ECS cluster using Terraform and Ansible.

## Usage

1. Once the deployment is successful, you can access your Flask application using the public endpoint of your ECS service.
2. Set any necessary environment variables for your application.
3. Customize the application as per your requirements.

## Contributing

Contributions are welcome! If you would like to contribute to this project, please follow these guidelines:

- Fork the repository and create a new branch for your feature or bug fix.
- Make your changes and ensure the code is properly formatted.
- Submit a pull request, describing your changes and any additional information.


