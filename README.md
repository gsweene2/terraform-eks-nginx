# Terraform Starter

## Step 0: Use template to create `.tfvars` file
```
cp vars/template.tfvars vars/dev-east.tfvars
```

## Step 1: Initialize Repo
```
terraform init
```

## Step 2: Plan Resources
```
terraform plan -var-file="vars/dev-east.tfvars" -out awesome-plan
```

## Step 3: Apply Resources
```
terraform apply "awesome-plan"
```

## Step 4: Update Kube Config on Machine
```
aws eks update-kubeconfig --name terraform-eks-nginx --region us-east-2
```
Expected Output:
```
Added new context arn:aws:eks:us-east-2:666666666666:cluster/terraform-eks-nginx to /Users/garrettsweeney/.kube/config
```

## Step 5: Create nginx deployment & service
```
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/nginx-service.yaml
```

## Step 6: Get Load Balancer Address and test
```
kubectl get service/nginx-service-loadbalancer |  awk {'print $1" " $2 " " $4 " " $5'} | column -t
# Curl
curl -silent abdcde0b86ec444978dc7aa0e5daad54-295517781.us-east-2.elb.amazonaws.com:80 | grep title
```
Expected results:
```
<title>Welcome to nginx!</title>
```
