AWS_REGION := eu-north-1
ECR_REPO := 533046675336.dkr.ecr.eu-north-1.amazonaws.com/valya-lab
IMAGE_TAG := latest

# Bulild, tag and push image to ECR
.PHONY: all
all: build tag push

# Build Docker image
# Remove platform argument in case you build the image on x86 architecture by default
.PHONY: build
build:
	docker buildx build --platform linux/amd64 -t flask-crud:$(IMAGE_TAG) .

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
