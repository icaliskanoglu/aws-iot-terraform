# AWS IOT resources with terraform

Create AWS IOT required resources and export needed configurations.

## What resources are created

1. things for each device id
2. thing-certificate
3. thing-policy
4. thing-assume-with-cert-policy
5. thing-service-role to access aws services via thing-certificate
6. thing-service-role-alias
7. thing-shadow-rule to sending shadow data to s3 bucket
8. thing-aws-resources
    1. thing-deployment-bucket: 
    2. thing-shadow-bucket
    3. thing-shadow-table to querying shadow data from athena
9. thing-deploy-policy
10. thing-deploy-role to access aws resources with role
11. thing-deploy-user to access aws resources with user
12. thing-configurations
    1. thing-certificate as file
    2. thing-certificate-public-key as file
    3. thing-certificate-private-key as file
    4. conf.json

conf.json
```
{
    "devices": ["dev-gorup-dev-id"],
    "thingGroup": "dev-gorup",
    "region": "eu-central-1",
    "roleAlias": "my-dev-gorup-service-role-alias",
    "deploymentBucket": "org-thing-my-dev-group-deployment",
    "version": "2020-06-12-21-41-36"
}
```

## Usage

uncomment terraform backend config in main.tf if you want to keep states in a s3 bucket

```
terraform {
  backend "s3" {
    bucket = "my-terraform-bucket"
    key    = "terraform/terraform.tfstate"
    region = "eu-central-1"
  }
}
```

run terraform commands
```
terraform init

terraform plan -var 'device_ids=["dev-id"]' -var 'organization_name=org' -var 'thing_group=dev-group'

terraform apply -var 'device_ids=["dev-id"]' -var 'organization_name=org' -var 'thing_group=dev-group'
```

* device_ids: list of unique device ids
* thing_group: name of the device group
* organization_name: name of the organization (product name etc.)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Related Documents
How to access aws resources with AWS IOT certificate and private key

https://aws.amazon.com/blogs/security/how-to-eliminate-the-need-for-hardcoded-aws-credentials-in-devices-by-using-the-aws-iot-credentials-provider/