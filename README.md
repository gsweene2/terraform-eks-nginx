# terraform-eks-nginx

## Step 0: Set alias & use template to create `.tfvars` file
```
alias k=kubectl
cp vars/template.tfvars vars/dev-east.tfvars
```
Be sure to update the values in your new `.tfvars` file

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

# StatefulSets

## Step 0: Set alias & use template to create `.tfvars` file
```
alias k=kubectl

cp vars/template.tfvars vars/dev-east.tfvars
```
Be sure to update the values in your new `.tfvars` file

## Step 1: Create storageclasses, statefulsets, & services

Create storageclasses:
```
k apply -f k8s/nginx-stateful/gp2-resizable-storage-class.yaml
k apply -f k8s/nginx-stateful/gp2-unresizable-storage-class.yaml
```

Create a statefulset with resizable volumes:
```
k apply -f k8s/nginx-stateful/nginx-statefulset-resizable.yaml
k apply -f k8s/nginx-stateful/nginx-service-resizable.yaml
```

Create a statefulset with unresizable volumes:
```
k apply -f k8s/nginx-stateful/nginx-statefulset-unresizable.yaml
k apply -f k8s/nginx-stateful/nginx-service-unresizable.yaml
```

## Step 2: Go into your container and create html files

There's a more efficient way to do this, but just write Hello World to both mounted volumes.

For the first replica:
```
k exec -it web-0 -- bash
echo "<h1>Hello World</h1>" > /usr/share/nginx/html/index.html
```

For the second replica:
```
k exec -it web-1 -- bash
echo "<h1>Hello World</h1>" > /usr/share/nginx/html/index.html
```

## Step 3: Get Load Balancer Address and test
```
k get service/nginx-service-statefulset-loadbalancer
```

Test with curl:
```
curl a79595abf7f784da39029f6ab337a440-1769525783.us-east-2.elb.amazonaws.com
<h1>Hello World</h1>
```

## Step 4: Test Volume Resizing

### When Resizable

Try setting 1Gi to 2Gi here:
```
k edit pvc www-web-0
```

### When Not Resizable

Try setting 1Gi to 2Gi here:
```
k edit pvc www-web-unresizable-0
```
You should see this error:
```
error: persistentvolumeclaims "www-web-unresizable-0" could not be patched: persistentvolumeclaims "www-web-unresizable-0" is forbidden: only dynamically provisioned pvc can be resized and the storageclass that provisions the pvc must support resize
```

### Check results

```
k get pvc

NAME                    STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
www-web-0               Bound    pvc-5bb45f87-cf20-4ccb-8083-06392b4ff670   2Gi        RWO            gp2-resizable     12m
www-web-1               Bound    pvc-f7fb5db1-704c-4282-a1a9-44c114af6534   1Gi        RWO            gp2-resizable     12m
www-web-unresizable-0   Bound    pvc-ace7b4e6-6080-4a6a-a6e4-0a4ca9933058   1Gi        RWO            gp2-unresizable   10m
www-web-unresizable-1   Bound    pvc-b2c1e209-5773-4d03-a97e-8ddb50708b44   1Gi        RWO            gp2-unresizable   9m41s
```
