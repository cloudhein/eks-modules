# EKS Infrastructure Provisioning with Terraform

This repository provides complete Terraform configurations for provisioning the foundational infrastructure of an Amazon EKS (Elastic Kubernetes Service) platform. The setup supports both stateless and stateful microservices, and includes the setup required for ingress controllers, persistent volumes via EBS CSI driver, and high availability networking.

---

## 🚀 Features

- Modularized Terraform code
- VPC with public and private subnets across availability zones
- EKS cluster provisioning with managed node groups
- IAM roles and OpenID Connect (OIDC) provider setup
- EBS CSI driver IAM policy and integration for stateful workloads
- S3 backend configuration for remote state management
- Preconfigured support for ingress setup (e.g., AWS Load Balancer Controller)

---

## 🧱 Modules Overview

### 🔹 VPC Module

Creates a robust and secure VPC, including:

- Public and private subnets in multiple Availability Zones (AZs)
- Internet Gateway for public traffic
- NAT Gateway for outbound traffic from private subnets
- Route tables and subnet associations

### 🔹 EKS Module

Handles provisioning of the Amazon EKS cluster and necessary components:

- EKS Control Plane provisioning with cluster endpoint and OIDC configuration
- Managed Node Groups deployed in private subnets for enhanced security
- IAM roles for EKS cluster and worker nodes
- OpenID Connect (OIDC) provider setup for Kubernetes service account IAM integration
- **Supports Stateful Applications** with persistent volume integration
- **EBS CSI Driver Setup** for dynamic volume provisioning
- **Ingress Controller Preconfiguration**, ready for deployment of the AWS Load Balancer Controller
- Addons like vpc-cni, kube-proxy, and coredns configured for enhanced networking and observability

---

## ⚙️ Getting Started

### 📌 Prerequisites

- Terraform must be installed.
- AWS CLI configured with appropriate IAM credentials
- `kubectl` installed and configured
- AWS account with necessary permissions to create VPC, EKS, IAM, etc.

### 📦 Installation & Deployment

Clone the repository and run the following commands:

```bash
# Initialize the Terraform working directory
terraform init

# Review the planned infrastructure changes
terraform plan

# Apply the changes to provision infrastructure
terraform apply
```

---

## 📂 Directory Structure

```
├── backend
│   ├── backend-access-user.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfstate
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── versions.tf
├── backend.tf
├── main.tf
├── modules
│   ├── eks
│   │   ├── ebs-csi-policy.tf
│   │   ├── eks_cluster_addons.tf
│   │   ├── ingress-policy.tf
│   │   ├── ingress-service-account.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc
│       ├── data.tf
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── README.md
├── variables.tf
└── versions.tf
```

---

## 📤 Outputs

After a successful `terraform apply`, you’ll get output values like:

### EKS Module Outputs

- eks_cluster_name: The name of the provisioned EKS cluster.

- eks_cluster_endpoint: The API server endpoint URL for the EKS cluster.

- eks_node_group_name: The name of the managed node group created for worker nodes.

### VPC Module Outputs

- vpc_id: The ID of the created Virtual Private Cloud (VPC).

- vpc_cidr_block: The CIDR block range assigned to the VPC.

- public_subnet_ids: A list of IDs for all public subnets created within the VPC.

- private_subnet_ids: A list of IDs for all private subnets created within the VPC.

- availability_zones: List of availability zones used for subnet distribution.

- internet_gateway_id: The ID of the Internet Gateway attached to the VPC.

- nat_gateway_id: The ID of the NAT Gateway used for outbound internet access from private subnets.

- nat_eip: The Elastic IP address allocated to the NAT Gateway.

- public_route_table_id: Route table ID associated with the public subnets.

- private_route_table_id: Route table ID associated with the private subnets.

---

## 🛡 Remote State Configuration

Remote state is managed via S3 bucket and state file locking supported:
```hcl
terraform {
  backend "s3" {
    bucket       = "remote-state-bucket-dev-007"
    key          = "terraform/dev/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
    profile      = "tf-s3-state-handler"
  }
}
```

---

## 📌 Notes

- Ensure your AWS profile has proper credentials and MFA if applicable.
- Use `kubectl get nodes` to validate your EKS worker nodes after provisioning.
- You can deploy the AWS Load Balancer Controller and other components post-provisioning.

---

# Key Configurations

## EKS Cluster
- Uses the *modules/eks* to create an EKS cluster with public endpoint access.
- Configures managed node groups with customizable instance types and scaling parameters.

## VPC

- Sets up public and private subnets across multiple Availability Zones and Fault-Tolerance Architecture.

- Configures routing with NAT Gateway for private subnet outbound access.

## Stateful Microservices
- Enables the AWS EBS CSI driver with an IAM role for persistent volume support.
- Configured with the *aws-ebs-csi-driver addon*.

## Ingress Policies
- Sets up the AWS Load Balancer Controller with an IAM role and Kubernetes service account for managing ALBs.
- Uses IRSA for secure AWS API access, eliminating the need for manual *eksctl* commands like *eksctl utils associate-iam-oidc-provider*.
- Pre-configured an ingress policies ans service accounts to expose the microservices via an *ingress ALB*.

## IAM and OIDC
- Automatically creates an IAM OIDC provider for the EKS cluster.
- Configures trust policies for service accounts (e.g., *aws-load-balancer-controller*, *ebs-csi-controller-sa*).

## 🤝 Contributions

Open issues and PRs are welcome! This project is built for learning and collaboration.

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙏 Acknowledgments

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Modules](https://github.com/terraform-aws-modules)

