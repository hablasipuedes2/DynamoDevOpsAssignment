# CRUD API Application with Flask and PostgreSQL

This repository contains a CRUD API built with Flask, containerized with Docker, and deployed to AWS EKS using Terraform and Kubernetes. PostgreSQL is used as the backend database.

## Prerequisites

- [Python 3.13](https://www.python.org/downloads/release/python-3130/)
- [Docker](https://docs.docker.com/get-docker/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Make](https://www.gnu.org/software/make/)

## Setup

### 1. Clone the repository

```sh
git clone <https://github.com/hablasipuedes2/DynamoDevOpsAssignment/tree/main/crud_api>
cd crud_api
```

### 2. Configure AWS credentials

Ensure your AWS CLI is configured with credentials that have permissions to manage ECR, EKS, IAM, and VPC resources:

```sh
aws configure
```

### 3. Build and Push Docker Image

Update `ECR_REPO` and `AWS_REGION` in the [Makefile](Makefile) if needed.

```sh
make login
make all
```

This will:
- Login to AWS ECR
- Build the Docker image for the Flask API
- Tag it for your ECR repository
- Push it to AWS ECR

## Infrastructure Deployment

### 1. Initialize and Apply Terraform

From the `terraform/` directory:

```sh
cd terraform
terraform init
terraform plan
terraform apply
```

This will provision:
- VPC and networking
- EKS cluster
- IAM roles and policies
- EBS storage class
- ECR repository

### 2. Update kubeconfig

After Terraform completes, update your kubeconfig to access the new EKS cluster:

```sh
aws eks --region <your-region> update-kubeconfig --name <your-cluster-name>
```

Replace `<your-region>` and `<your-cluster-name>` with your actual values (see Terraform outputs).

## Deploying to Kubernetes

From the root directory apply the manifests STRICTLY following the order below:

```sh
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/db-configmap.yaml
kubectl apply -f k8s/db-credentials.yaml
kubectl apply -f k8s/flask-sa-ecr.yaml
kubectl apply -f k8s/self-signed-issuer.yaml
kubectl apply -f k8s/postgres-ca.yaml
kubectl apply -f k8s/postgres-server-cert.yaml
kubectl apply -f k8s/ebs-storage-class.yaml
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/flask-service.yaml
```

## Accessing the Flask API

Find the external service endpoint:

```sh
kubectl get svc -n flask-api
```

Look for the `EXTERNAL-IP` of the `flask-service`. Access the API at `http://<EXTERNAL-IP>:<PORT>`.

## API Endpoints

The following endpoints are available in the Flask API:

| Method | Endpoint             | Description                    | Request Body (JSON)         |
|--------|----------------------|--------------------------------|-----------------------------|
| GET    | `/`                  | Health check, returns "Hello world!" | -                   |
| GET    | `/ping`              | Checks DB connection, returns "pong" | -                   |
| POST   | `/users`             | Create a new user              | `{ "name": "...", "email": "..." }` |
| GET    | `/users`             | Get all users                  | -                           |
| PUT    | `/users/<user_id>`   | Update user by ID              | `{ "name": "...", "email": "..." }` |
| DELETE | `/users/<user_id>`   | Delete user by ID              | -                           |

**Example: Create a User**

```sh
curl -X POST http://<EXTERNAL-IP>:<PORT>/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice", "email": "alice@example.com"}'
```

**Example: Get All Users**

```sh
curl http://<EXTERNAL-IP>:<PORT>/users
```

## Cleaning Up

To destroy all infrastructure:

```sh
cd terraform
terraform destroy
```

To remove Kubernetes resources:

```sh
kubectl delete -f k8s/
```

---

## Project Structure

- `app.py` - Flask API application
- `db.py` - Database connection logic
- `k8s/` - Kubernetes manifests
- `terraform/` - Terraform infrastructure code
- `Makefile` - Docker build/push automation

---
