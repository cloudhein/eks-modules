# EKS Infrastructure Provisioning with Terraform

This repository provides a comprehensive suite of Terraform modules to provision a complete Amazon EKS ecosystem. It is designed for production readiness, offering customized VPC networking, secure ingress and secrets management, and fine-grained access control. The architecture supports stateful microservices via the EBS CSI driver and implements robust, robust node scaling strategies using cluster autoscaler.

---

## 🚀 Key Features

### Core Infrastructure
- **Modularized Terraform Architecture**: Designed for high maintainability, reusability, and clean separation of concerns.

- **High Availability Networking**: Multi-AZ VPC architecture with strictly separated public and private subnets.

- **Production-Ready EKS**: Fully managed EKS cluster with managed node groups and optimized configurations.

- **Robust State Management**: Remote Terraform state management using S3 backend with native state file locking for team collaboration.

### Security & IAM
- **Flexible Cluster Authentication**: Configurable support for EKS Access Entries (API mode), legacy ConfigMap, or hybrid authentication (API_AND_CONFIG_MAP) for seamless access management.

- **Fine-Grained Access Control**: Full implementation of IAM Roles for Service Accounts (IRSA) via OIDC provider.

- **Secrets Management Integration**: AWS Secrets Manager integration for secure, rotated credential management.

- **Least Privilege Security**: Strict IAM policies applied to all service accounts to minimize attack surface.

- **Automated Authentication**: Secure service account automation leveraging the Terraform Kubernetes provider.

### Storage & Persistence
- **Stateful Workloads**: Integrated EBS CSI driver enabling dynamic persistent volume (PV) provisioning for databases and stateful apps.
- **Stateful node groups**: with dedicated taints and labels

### Networking & Ingress
- **Advanced Ingress**: AWS Load Balancer Controller pre-configured with IRSA for automated ALB provisioning.

- **Application Load Balancer (ALB)**: Native support for Kubernetes Ingress resources backed by AWS ALB.

- **Network Optimization**: Tuned configurations for VPC CNI, CoreDNS, and kube-proxy for maximum throughput and reliability.

### Node Auto-scaling
- **Proven Auto-scaling:** Reliable node scaling using the industry-standard **Cluster Autoscaler** to dynamically adjust Auto Scaling Group sizes based on workload demand.

### Secrets Injection
- **CSI Driver Integration**: AWS Secrets Store CSI Driver pre-installed for seamless secret retrieval.


---

## 🧱 Architecture Overview

### Overview Architecure of EKS Infrastructure

![Infrasture Diagram](./images/network-architecture.png)

### LLD Architecure of EKS Infrastructure

![Infrasture Diagram](./images/eks-architecture-diagram.png)

### EKS IRSA Permissions & Relationship

![EKS IRSA Diagram](./images/IRSA-1.png)

![EKS IRSA Diagram](./images/IRSA-2.png)

### EKS IRSA & OIDC Provider Relationship Workflow

![EKS IRSA Diagram](./images/OIDC-provider.png)

## 📦 Modules Overview

### 🔹 VPC Module

Creates a secure, scalable VPC foundation:

- **Multi-AZ deployment** across 3 availability zones
- **Public subnets** for load balancers and NAT gateways
- **Private subnets** for EKS nodes and sensitive workloads
- **Internet Gateway** for public internet access
- **NAT Gateway** with Elastic IP for outbound private traffic
- **Route tables** with proper associations and routing rules

### 🔹 EKS Module
Comprehensive EKS cluster setup with enterprise features:

#### Core Cluster & Access
- **Modular Architecture**: Clean separation of resources (eks-cluster.tf, node-group.tf) for maintainability.

- **Modern Authentication** using EKS Access Entries (access_entry.tf) for API-based access management.

- **OIDC Identity Provider** enabled for IAM Roles for Service Accounts (IRSA).

- **Security Groups** fine-tuned for Control Plane and Worker Node communication.

#### Compute & Scaling
- **Managed Node Groups** for stable, low-maintenance worker node management.

- **Stateful node group** with dedicated taints and labels for persistent workloads

- **Cluster Autoscaler** integration (helm-cluster-autoscaler.tf) for automated scaling of node groups based on workload demand.

- **Auto-scaling Policies** pre-configured IAM roles (cluster-autoscaler.tf) to allow nodes to scale.

#### Storage & Secrets
- **EBS CSI Driver integration** (ebs-csi-policy.tf) for stateful persistent volumes.

- **Secrets Store CSI Driver** (secret-store-csi-*.tf) for securely syncing AWS Secrets Manager secrets into Kubernetes pods.

#### Networking & Ingress
- **Ingress Ready** with IAM policies and Service Accounts for the AWS Load Balancer Controller (ingress-*.tf).

- **Standard Add-ons** including VPC CNI, CoreDNS, and kube-proxy managed via EKS Add-ons.

#### Observability
- **Metrics Server** (helm-metrics-server.tf) deployment included for Horizontal Pod Autoscaling (HPA) support.

---

---

## ⚙️ Getting Started

### 📌 Prerequisites

- **Terraform** >= 1.9.0 (required for native S3 state locking)
- **AWS CLI** configured with appropriate credentials
- **kubectl** >= 1.21
- **helm** >= 3.0 (for add-on installations)
- **AWS account** with EKS, VPC, IAM, and EC2 permissions

### 🚀 Deployment Steps

1. **Initialize Terraform:**
```bash
terraform init
```

2. **Review the plan:**
```bash
terraform plan
```

3. **Apply the configuration:**
```bash
terraform apply
```

4. **Configure kubectl:**
```bash
aws eks --region ap-southeast-1 update-kubeconfig --name my-eks-cluster
```

5. **Verify the setup:**
```bash
kubectl get nodes
kubectl get pods -A
helm list -A
```

---

## 📂 Directory Structure

```
├── backend/                                   # Remote state configuration
│   ├── backend-access-user.tf                 # IAM user for backend access
│   ├── main.tf                                # S3 bucket creation
│   ├── outputs.tf                             # Backend resource outputs
│   ├── variables.tf                           # Backend variables
│   └── versions.tf                            # Provider versions for backend
├── modules/
│   ├── eks/                                   # EKS Module
│   │   ├── access_entry.tf                    # EKS Access Entries (API Auth mode)
│   │   ├── cluster-autoscaler.tf              # IAM roles for Cluster Autoscaler
│   │   ├── ebs-csi-policy.tf                  # IAM policy for EBS CSI driver
│   │   ├── eks-cluster-ng-iam-roles.tf        # IAM roles for Managed Node Groups
│   │   ├── eks-cluster.tf                     # Main EKS cluster resource
│   │   ├── eks_cluster_addons.tf              # Managed Add-ons (CoreDNS, VPC CNI,EBS CSI driver, etc.)
│   │   ├── helm-cluster-autoscaler.tf         # Helm release for Cluster Autoscaler
│   │   ├── helm-metrics-server.tf             # Helm release for Metrics Server
│   │   ├── ingress-policy.tf                  # IAM policy for AWS Load Balancer Controller
│   │   ├── ingress-service-account.tf         # Service Account for Ingress
│   │   ├── node-group.tf                      # EKS Managed Node Groups configuration
│   │   ├── secret-store-csi-policy.tf         # IAM policy for Secrets Store CSI
│   │   ├── secret-store-csi-service-accounts.tf # Service Accounts for Secrets Store
│   │   ├── security-group.tf                  # Security Groups (Control Plane & Worker)
│   │   ├── outputs.tf                         # Module outputs
│   │   └── variables.tf                       # Module variables
│   └── vpc/                                   # VPC Module
│       ├── main.tf                            # VPC, subnets, IGW, NAT gateways
│       ├── data.tf                            # Data sources (Availability Zones)
│       ├── outputs.tf                         # VPC outputs
│       └── variables.tf                       # VPC variables
├── main.tf                                    # Root module configuration
├── variables.tf                               # Root variables
├── outputs.tf                                 # Root outputs
├── backend.tf                                 # Backend configuration
└── versions.tf                                # Provider versions
```

---

## 🤝 Contributing

We welcome contributions! Please read our contributing guidelines and submit pull requests for any improvements.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [AWS EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Cluster Autoscaler Documentation](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)

---

## 📞 Support

For questions and support:
- Create an issue in this repository
- Check the [AWS EKS Troubleshooting Guide](https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html)
- Review Terraform AWS Provider issues