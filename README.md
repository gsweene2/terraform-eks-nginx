# Terraform Starter

## Step 0: Create `.tfvars` file
```
mkdir vars && echo 'aws_region = "us-east-1"' > vars/dev-east.tfvars
```

## Step 1: Initialize Repo
```
terraform init
```

## Step 2: Plan Resources
```
terraform plan -var-file="vars/dev-east.tfvars"
```

## Step 3: Apply Resources
```
terraform apply -var-file="vars/dev-east.tfvars"
```
