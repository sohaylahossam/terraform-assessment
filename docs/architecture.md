# Architecture Documentation

## Architecture Overview

This system implements a production-ready containerized Flask application on Google Cloud Platform using Infrastructure as Code principles. 

### High-Level System Design
```
┌─────────────────┐
│   Internet      │
│   Users         │
└─────────┬───────┘
│
▼
┌─────────────────────────────────┐
│   Global Load Balancer          │
│   - SSL Termination             │
│   - Static IP: 34.102.246.240   │
│   - HTTP → HTTPS Redirect       │
│   - DDoS Protection             │
└─────────────┬───────────────────┘
│
▼
┌─────────────────────────────────┐
│   Network Endpoint Group        │
│   - Serverless NEG              │
│   - Cloud Run Integration       │
└─────────────┬───────────────────┘
│
▼
┌─────────────────────────────────┐
│   Cloud Run Service             │
│   - Serverless Containers       │
│   - Auto-scaling: 0-5 instances │
│   - Python Flask Application    │
│   - VPC Integration             │
└─────────────┬───────────────────┘
│
┌─────────┼─────────┐
│         │         │
▼         ▼         ▼
┌─────────┐ ┌─────────┐ ┌─────────────────┐
│   VPC   │ │ Storage │ │   Monitoring    │
│- Subnets│ │- Images │ │- Uptime Checks  │
│- Firewall││- State  │ │- Dashboards     │
│- Connect││- Assets │ │- Alert Policies │
└─────────┘ └─────────┘ └─────────────────┘

```

## Component Description
### Request Flow

1. **User Request** → Global Load Balancer (HTTPS endpoint)
2. **SSL Termination** → Load balancer handles SSL/TLS
3. **Health Check** → Backend health validation
4. **Network Endpoint Group** → Routes to Cloud Run service
5. **Cloud Run Processing** → Flask application processes request
6. **Response** → JSON response via same path back to user
7. **Logging & Monitoring** → All layers generate metrics and logs

### 1. Global Load Balancer

**Purpose**: Distributes traffic to the Cloud Run app securely and reliably.

**Components**:
- **Global Static IP**: 34.102.246.240 for consistent access
- **SSL Certificate**: Google-managed certificate with automatic renewal
- **Backend Service**: Connects to Cloud Run
- **Health Check**: Monitors `/health` endpoint
- **URL Maps**: Routes traffic and redirects HTTP → HTTPS
- **Forwarding Rules**: Handles HTTP and HTTPS traffic

**Features**:
- Low-latency global Anycast IP
- Automatic HTTPS redirection
- DDoS protection
- Custom domain support with SSL
- Simple traffic routing and monitoring

### 2. Cloud Run Service

**Purpose**: Serverless container platform hosting the Flask application.

**Configuration**:
- **Service Name**: terraform-assessment-dev
- **Image**: us-central1-docker.pkg.dev/terraform-assess-26565/terraform-assessment-repo/app:latest
- **Scaling**: 0-5 instances with scale-to-zero capability
- **Resources**: 1 vCPU, 512MB memory per instance
- **Concurrency**: 80 requests per instance
- **VPC Integration**: Connected via VPC connector for security

**Service Account**: Dedicated service account with minimal required permissions.

### 3. VPC Network Infrastructure

**VPC Network**: terraform-assessment-vpc (10.0.1.0/24 in us-central1)

**Firewall Rules**:
- Health checks allowed from Google IP ranges
- Load balancer can reach Cloud Run instances
- Default deny for all other traffic

**VPC Connector**: 
- **Name**: terraform-asses-connector
- **CIDR**: 10.0.2.0/28
- Connects Cloud Run securely to VPC resources

### 4. Artifact Registry

**Repository**: terraform-assessment-repo (Docker, us-central1)- **Size**: 50.7MB for application image
- **Features**: 
  - Vulnerability scanning enabled
  - Version management with tags
  - IAM-controlled access
  - Integration with Cloud Build

  ### 5. Cloud Storage

**Terraform State Management**:
- **Bucket**: terraform-assess-26565-terraform-state
- **Purpose**: Remote Terraform state storage with locking
- **Features**: Versioning enabled, encryption at rest
- **Access**: Restricted to Terraform service accounts

**Application Artifacts**:
- **Bucket**: terraform-assess-26565-dev-artifacts
- **Purpose**: Static assets and application backups
- **Lifecycle**: Automatic cleanup of old versions

### 6. Monitoring and Observability

**Components**:
- Uptime check on /health endpoint
- Custom dashboards for key metrics
- Alerts for high error rates (>5%)
- Logs collected and stored centrally

**Monitored Metrics**:
- Request count and status codes
- Response latency (p50, p95, p99)
- Load balancer backend health
- Cloud Run scaling events
- SSL certificate expiration

## Design Decisions

**Google Cloud Platform**:

- Easy integration of services
- Serverless hosting with Cloud Run
- Global reach via Load Balancer
- Pay-per-use cost model
- Built-in security and compliance

**Flask Framework**:
- Lightweight and easy for APIs
- Leverages Python libraries and team expertise
- Fast startup, low resource use
- Simple testing and development

**Infrastructure as Code (Terraform)**:
- Remote state in GCS with versioning
- Reusable modules for core infrastructure
- Git-tracked changes for version control
- Supports multiple environments (dev/staging/prod)

## Security Considerations

### Network Security

**Perimeter Defense**:
- **Load Balancer**: First line of defense with DDoS protection
- **Firewall Rules**: Restrictive ingress controls
- **VPC Isolation**: Private network for internal communication
- **HTTPS Only**: All traffic encrypted with SSL/TLS

**Access Control**:
- **IAM Policies**: Role-based access control for all resources
- **Service Accounts**: Dedicated identities with minimal permissions
- **API Security**: Authentication required for management operations
- **Audit Logging**: All access attempts logged and monitored

### Application Security

**Container Security**:
- Uses secure Python slim base image
- Automatic vulnerability scanning
- Runs as non-root user
- Secrets managed via environment variables


### Data Security

**Encryption**:
- All storage encrypted with Google-managed keys
- HTTPS/TLS for all communications
- Terraform state encrypted in Cloud Storage

**Access Logging**:
- Logs all API calls and application activity
- Audits Terraform changes
- Tracks and alerts on failed access attempts

## Scalability
### Current Scaling Characteristics

**Cloud Run Scaling:**:
- 0–5 instances, adjusts automatically to traffic
- Each instance handles 80 requests (up to 400 total)
- Fast response times (<100ms), cold start 1–3s

**Auto-scaling Triggers**:
- CPU above 60%
- Request queue buildup
- High memory usage
- No traffic → scales to zero

## Improvements
- **Custom Domain**: Configure SSL certificate for branded domain
- **Enhanced Monitoring**: Custom metrics and SLO tracking
- **Automated Deployments**: GitHub Actions integration for CI/CD

## Cost Estimation

### Current Monthly Costs (Production Configuration)

| Service | Usage | Monthly Cost |
|---------|--------|--------------|
| **Global Load Balancer** | 1 forwarding rule | $18.00 |
| **Global Static IP** | 1 reserved IP | $1.50 |
| **Cloud Run** | Low traffic (~10K requests) | $2.00 |
| **VPC Connector** | Always-on connector | $9.00 |
| **Artifact Registry** | 50MB storage | $0.50 |
| **Cloud Storage** | <1GB state + artifacts | $0.20 |
| **Monitoring** | Basic metrics + alerts | $2.00 |
| **Data Transfer** | Minimal egress | $1.00 |
| **Total** | | **$34.20** |
