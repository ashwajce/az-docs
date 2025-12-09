# ABC Azure Key Vault

## Overview
ABC uses a hardened Key Vault configuration with strict governance for secrets, certificates, and keys.

## Access Control
- RBAC only (Access Policies disabled)
- Only managed identities allowed for application access
- Break-glass accounts monitored and rotated

## Network Restrictions
- Private endpoint only
- Firewall allows only ABC VNets
- No public network access

## Policies Enforced
- Soft delete enabled (90 days)
- Purge protection on
- Logging enabled for all operations
- Secrets rotation policy defined for ABC workloads

## Automation
- Key Vault instances deployed using ABC Terraform modules
- Secret injection via CSI driver for AKS workloads

