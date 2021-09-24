# Terraform Challenge to provision AWS Infrstructure

Terraform Code to create AWS Infrastructure which:
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

### Future Iteration
1. Remove hardcoding of any resource configuration and make it parameterized, which will help us to tweak the configuration based on environment we are going to deploy in. Example. Each environment [Eg: Dev, Staging, Prog] might require differnet replica to handle load
2. Use Terragrunt to manage Terraform's Configuration DRY, will be usefull when we deal with multiple environments
3. Ensure Naming convention is followed and consistent in all components. This will help us to identify our resource when we deploy our application in multiple region, environment and accounts. Or even in client environment. 
4. Better use of resource tags, which will help  to segregate our resources and also to filter cost incured 
5. The Code structure can be even more modularized, which will help other develpers to jump in and contribute.


### Production Ready Checklist :
1. State management has to be configured. (Also Enable version control)
2. Enabling HTTPS via Custom DNS and ACM 
3. Cloudwatch Resource Monitoring, Alerting has to be introduced in terraform
4. ALB/ VPC Flow Logs has to be Enabled for better visibility
5. Benchmark of the application has to be done to set autoscaling  units

