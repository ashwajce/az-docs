# ABC Azure Kubernetes Service (AKS)

## Overview
ABC operates a standardized AKS platform optimized for security, governance, and operational consistency.

## Cluster Standards
- Kubernetes version pinned by ABC platform team
- System + User node pools separated
- Default network plugin: Azure CNI
- Calico enabled for network policies

## Security
- AAD integration enforced
- Pod Identity via Managed Identity
- ImagePullPolicies restricted to ABC Private Container Registry

## Networking
- Internal load balancers only for sensitive workloads
- DNS integrated with ABC Core DNS
- Egress controlled through Azure Firewall

## Observability
- Centralized logging to Log Analytics Workspace
- Prometheus + Grafana stack deployed via Helm
- Mandatory diagnostic settings enabled by policy

## Deployment Model
- GitOps using Flux v2
- ABC-specific Helm charts stored in internal ACR

