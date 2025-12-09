# Azure Kubernetes Service (AKS) - Generic Documentation

## Overview
Azure Kubernetes Service (AKS) provides managed Kubernetes clusters for containerized workloads with integrated security and scalability features.

## Cluster Configuration
- Node pools: System and User separation
- Azure CNI or Kubenet depending on network strategy
- Private cluster recommended for production

## Security
- Azure AD integration for RBAC
- Managed Identities for workload authentication
- Image policies and trusted registries

## Networking
- Internal or external load balancers
- Network policies via Azure or Calico
- Egress control via Firewall/NAT gateway

## Observability
- Container insights enabled
- Logging to Log Analytics
- Metrics scraped via Prometheus add‑on or Helm installation

## Deployment Patterns
- GitOps with Flux or ArgoCD
- Helm charts for deployments
- ACR integration for images

