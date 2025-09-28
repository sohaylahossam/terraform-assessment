# Terraform Assessment

Containerized Python Flask deployed on GCP using Terraform

---

## Architecture Overview

- Application: Python Flask with health endpoint
- Container Platform: Google Cloud Run
- Load Balancer: Google Cloud Load Balancer with SSL/HTTPS
- Infrastructure: Terraform with modular design
- Networking: Custom VPC with subnets and firewall rules
- Storage: Artifact Registry + Cloud Storage
- Monitoring: Cloud Monitoring with dashboards and alerts
- CI/CD: GitHub Actions workflow

---

## Prerequisites

- Google Cloud SDK (https://cloud.google.com/sdk/docs/install) (gcloud CLI)
- Terraform https://www.terraform.io/downloads) >= 1.0 
- Docker (https://docs.docker.com/get-docker/) 
- Python 3.11+ (https://www.python.org/downloads/) 
- Git (https://git-scm.com/downloads)

---

## GCP Requirements

- Google Cloud account with billing enabled 
- Project with Editor/Owner permissions 
- Required APIs enabled (see setup instructions)

---

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/sohaylahossam/terraform-assessment.git
cd terraform-assessment

--- 
```
### 2. Set up Google Cloud Platform (GCP)

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

---
```
### 3. Create Service Account for Terraform

```bash
gcloud iam service-accounts create terraform-sa --display-name "Terraform Service Account” --project YOUR_PROJECT_ID
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID —member=“serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" —role=“roles/editor"
gcloud iam service-accounts keys create ~/terraform-sa.json --iam-account terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS="/home/sohaylahossamm/terraform-sa.json"
gcloud auth list
gcloud auth list

---
```
### 4. Enable required APIs

```bash
gcloud services enable \ compute.googleapis.com \ run.googleapis.com \ artifactregistry.googleapis.com \ cloudbuild.googleapis.com \ storage.googleapis.com \ monitoring.googleapis.com \ logging.googleapis.com \ vpcaccess.googleapis.com

---
```
### 5.Build and Deploy Application locally (Optional)

```bash
cd app 
# Test locally first 
python3 -m venv venv 
source venv/bin/activate 
pip install -r requirements.txt 
python src/app.py 
# Test on http://localhost:8080 
docker build -t terraform-assessment:latest .  # Build container 
docker run -p 8080:8080 terraform-assessment:latest # Test container

---
```
### 6.Push to Artifact Registry (Optional)

```bash
# Create repository 
gcloud artifacts repositories create terraform-assessment-repo —repository-format=docker — location=us-central1

# Configure Docker 
gcloud auth configure-docker us-central1-docker.pkg.dev

# Tag and push
 docker tag terraform-assessment:latest \ us-central1-docker.pkg.dev/YOUR_PROJECT_ID/terraform-assessment-repo/app:latest 
docker push us-central1-docker.pkg.dev/YOUR_PROJECT_ID/terraform-assessment-repo/app:latest

---
```
### 7. Deploy Infrastructure

```bash
# Navigate to Terraform environment 
cd terraform/environments/dev

# Update variables 
cp terraform.tfvars.example terraform.tfvars 
# Edit: project_id, image_url, domain_name

# Initialize and deploy 
terraform init 
terraform plan
terraform apply
---
```
## Configuration
Terraform variables are defined in terraform.tfvars and variables.tf. Key variables:
 | Variable| Description |
|:-----------|:---|
| project_id    | GCP Project ID  |
| region       | GCP region (e.g., us-central1)  | 
| app_name | Name of your application |
| environment | Environment (e.g., dev,prod|
| image_url | Container image URL for Cloud Run |
| domain_name | Domain for Load Balancer |
| notification_channels | Alert channels for monitoring | 

---
## Testing

### 1. Apply deployment and get service_url from the output:

```bash
terraform apply
curl https://terraform-assessment-dev-xxxxxxxxx-uc.a.run.app
curl https://terraform-assessment-dev-xxxxxxxxx-uc.a.run.app/health
---
```
### 2. Test locally with Docker as previously mentioned 
---
## Logging

### 1. Check Cloud Run logs

```bash
gcloud run services logs read terraform-assessment-dev —region=us-central
---
```
## Cleanup

```bash
terraform destroy
```
---
### Verify cleanup

```bash
# Check for remaining resources
gcloud run services list
gcloud compute forwarding-rules list
gcloud compute addresses list --global
---
```
## Troubleshooting
Authentication errors: Ensure GOOGLE_APPLICATION_CREDENTIALS points to the correct service account JSON.
Permissions errors: Confirm the service account has roles/editor or required roles.
Load Balancer issues: Deploy backend services and Cloud Run before the Load Balancer.

---

