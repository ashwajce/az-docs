# ABC Cloud Landing Zone

## Overview
ABC’s Landing Zone is designed to standardize cloud deployments across all business units while enforcing security, compliance, and operational baselines.

## Architecture Principles
- Centralized management groups
- Policy-driven governance
- Standardized networking
- Automated provisioning

## Management Groups
- **ABC-Root**
- **ABC-Platform**
- **ABC-Workloads**
- **ABC-Sandbox**

## Networking
- Hub-spoke model
- Central Firewall in Hub
- Shared Services VNet
- Peering enforced via policies

## Identity & Access
- Conditional Access enforced
- MFA mandatory
- RBAC aligned to ABC roles

## Policies
Key policies deployed:
- Allowed locations
- Required tags: `CostCenter`, `Owner`, `Environment`
- Key Vault soft-delete enabled
- Diagnostic logs mandatory

## Automation
- Deployed through Terraform with ABC modules
- Pipelines integrated with Azure DevOps
