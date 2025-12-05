# Azure Kubernetes Service (AKS) Landing Zone Documentation

## 1. Overview
Azure Kubernetes Service (AKS) Landing Zone provides a standardized, secure, and scalable foundation for deploying and operating Kubernetes workloads in Azure. It defines architecture, governance, security, networking, identity, and operational patterns required for running enterprise-grade container platforms.

---

## 2. Core Principles
- Enterprise‑grade security and governance
- Standardized cluster configuration
- Automated infrastructure deployment (Terraform/Bicep)
- Centralized monitoring and logging
- Identity-driven access control
- Network isolation and zero‑trust boundaries
- Consistent workload onboarding

---

## 3. Architecture Components

### 3.1 High-Level Architecture
- AKS Cluster (System + User Node Pools)
- Azure CNI networking
- Azure Load Balancer or Application Gateway
- Azure Container Registry (ACR)
- Log Analytics Workspace
- Key Vault for secrets
- Azure AD Identity Integration
- Azure Monitor & Defender for Cloud

---

## 4. Identity & Access Management

### 4.1 Azure AD Integration
- Enable **AKS-managed Azure AD**
- RBAC tied to Azure AD groups
- Disable local Kubernetes accounts

### 4.2 RBAC Structure
Recommended roles:
- **Cluster Admin** – platform engineering
- **Cluster Operator** – SRE/DevOps teams
- **Namespace Admins** – application teams
- **View-only / Audit roles**

### 4.3 Managed Identities
- System-assigned MI for the cluster
- User-assigned MI for workloads
- Use MI for:
  - ACR Pull
  - Key Vault access
  - Storage operations

---

## 5. Networking

### 5.1 Network Model
Recommended: **Azure CNI with Dynamic IPAM**
- VNet + Subnets:
  - `aks-system`
  - `aks-user`
  - `ingress`
  - `private-endpoints`
- Private API Server enabled
- UDRs for traffic control

### 5.2 Ingress
Options:
- App Gateway Ingress Controller (AGIC)
- NGINX Ingress Controller
- Istio / Ambient Mesh (optional)

### 5.3 Egress Control
- Azure Firewall
- NAT Gateway
- Restrict all outbound traffic unless required

---

## 6. Security

### 6.1 Security Baselines
- Private cluster mode
- Pod Security Policies / Azure PSP (OPA Gatekeeper)
- Restrict privileged containers
- Use Key Vault Provider for Secrets Store CSI Driver
- Restrict public load balancers

### 6.2 Workload Identity
Use **Azure AD Workload Identity** instead of pod-managed identities.

### 6.3 Container Registry Security
- Enable Content Trust
- Enable container scanning (ACR task or Defender)

### 6.4 Defender for Kubernetes
Enable:
- Threat detection
- Image scanning
- CIS compliance monitoring

---

## 7. Node Pools

### Node Pool Strategy
- **System Node Pool**
  - Linux only
  - Minimal workload placement
- **User Node Pools**
  - Workload-specific pools
  - Autoscaling enabled
  - Optional Windows pools

### Recommended Practices:
- Separate pools for dev, qa, prod workloads
- Use taints/tolerations for workload placement

---

## 8. Observability

### 8.1 Logging
Send logs to:
- Log Analytics Workspace
- Container Insights

Capture:
- Control plane logs
- Node logs
- Container stdout/stderr

### 8.2 Monitoring
Enable:
- Azure Monitor for Containers
- Prometheus (managed or self-hosted)
- Grafana dashboards

### 8.3 Alerts
Examples:
- Node not ready
- Pod restart loops
- High CPU/memory
- API server latency
- Ingress failures

---

## 9. Secrets & Configuration

### Recommended:
- Azure Key Vault with CSI Driver
- No plain-text secrets in configs
- Use ConfigMaps for non-sensitive data
- External Secrets Operator (optional)

---

## 10. Deployment Automation

### 10.1 IaC
Use:
- Terraform modules or Azure Landing Zone Terraform accelerator
- Bicep ALZ modules

Artifacts:
- Network
- AKS cluster
- ACR
- Monitoring
- Ingress

### 10.2 CI/CD Pipelines
Use GitHub Actions or Azure DevOps:
- Build & scan images
- Push to ACR
- Deploy to AKS using GitOps or Helm

---

## 11. GitOps

### Recommended GitOps Tools:
- ArgoCD
- Flux v2

GitOps Advantages:
- Declarative deployments
- Version-controlled cluster state
- Drift detection

---

## 12. Backup & DR

### Backup Options:
- Velero
- Azure Backup for AKS (new service)

### DR Strategy:
- Multi-region clusters
- Geo-redundant ACR
- Workload replication via GitOps

---

## 13. Cost Management
- Use cluster autoscaler
- Use spot node pools where feasible
- Turn on Azure Advisor recommendations
- Track namespace or app cost via Kubecost or Azure Cost Allocation

---

## 14. Workload Onboarding Guide
Teams must provide:
- Namespace request
- RBAC mappings
- Resource quotas
- Ingress rules
- Config/secret requirements
- Logging/monitoring needs

---

## 15. References
- AKS Baseline Architecture: https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/secure-baseline
- Azure CNI: https://learn.microsoft.com/azure/aks/concepts-network
- Workload Identity: https://learn.microsoft.com/azure/aks/workload-identity-overview
