# Azure Key Vault (Generic)

## Overview
Azure Key Vault stores secrets, keys, and certificates securely, supporting encryption, access control, and automated rotation.

## Access Control
- RBAC preferred over Access Policies
- Managed Identities recommended for applications
- Principle of least privilege enforced

## Networking
- Private endpoint access
- Firewall restrictions for trusted networks
- Public network disabled (recommended)

## Security Policies
- Soft-delete enabled
- Purge protection enabled
- Logging and monitoring of vault operations

## Automation
- Deployment via Terraform/Bicep templates
- Secret loading through DevOps pipelines
- CSI driver integration for AKS workloads

