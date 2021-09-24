# Terraform to provision AWS Infrstructure

Terraform Project to create AWS Infrastructure which:
- Runs the container workload (we recommend ECS)
- Exposes the application to the internet over HTTPS in some way

### Project Structure 

        .
        ├── input_variable.tf
        ├── main.tf
        ├── modules
        │   ├── ecs_deploy
        │   │   ├── config_asg.tf
        │   │   ├── input_variable.tf
        │   │   └── main.tf
        │   ├── gateway_https_private
        │   │   ├── input_variable.tf
        │   │   └── main.tf
        │   ├── load_balancer
        │   │   ├── input_variable.tf
        │   │   └── main.tf
        │   └── networks
        │       ├── input_variable.tf
        │       └── main.tf
        └── values.json

### Module Description

There are 4 Modules in this project, 

- **`Networks`**
    -   Reused the VPC Module from [Terraform AWS Modules](https://registry.terraform.io/namespaces/terraform-aws-modules) to create network components
         -   Components : VPC, IGW, NACL, RouteTables, 2 Private Subnets, 2 private subnets and a NAT Gateway
- **`Load Balancer`**
    - In This module, we create LoadBalancer and its dependant component to expose our service in ECS 
         - Security Group (Allows only 80 from VPC)
         - Internal Application  Load balancer (Deployed in Private Subnet)
         - Target Group (Listening to Container Application port)
         - Listener (Port 80:Target Group)
- **`ecs_deploy`**
     - In this module, we create ecs and its dependant components to deploy our services
         - Security Group (Allows only 80 from VPC)
         - Launch Configuration  
         - Autoscaling Group (uses Launch Config to spin up instances, Deploys in private subnet)
         - Task Definition (Container image's configurations)
         - Capacity provider
         - ECS 
         - ECS Service 
- **`api_gateway_https`**
     - This module will helps us to create a Endpoint to access our application using API Gateway Service.
         - Security Group (Allows only 80 from VPC)
         - VPC Link (For our VPC and ALB Listener)
         - API Integration (HTTP_PROXY and VPC Link)
         - Routes (/ and $Default route pointing to the integration)
         - Stage 
         - API
         

### PreRequisite

- Install Terraform
- Configure AWS CLI 
- Replace `container_image_id` in values.json to you ecr image uri.
- Replace `application_container_port` in values.json to you ecr image uri.


### Run Below commands to provision infrastructure

```sh
terraform init
terraform plan -var-file="values.json"  
terraform apply -var-file="values.json"  
```

