AWS_REGION := eu-north-1
ECR_REPO := 533046675336.dkr.ecr.eu-north-1.amazonaws.com/valya-lab
IMAGE_TAG := latest

# Default target
.PHONY: all
all: build

# Build Docker image
.PHONY: build
build:
	docker build -t flask-crud:$(IMAGE_TAG) .

# Tag image for ECR
.PHONY: tag
tag:
	docker tag flask-crud:$(IMAGE_TAG) $(ECR_REPO):$(IMAGE_TAG)

# Login to ECR
.PHONY: login
login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ECR_REPO)

# Push Docker image to ECR
.PHONY: push
push: login tag
	docker push $(ECR_REPO):$(IMAGE_TAG)
	@echo "✅ Image pushed: $(ECR_REPO):$(IMAGE_TAG)"

# Convenience command to build & push in one step
.PHONY: build-push
build-push: build push
