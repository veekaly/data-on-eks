variable "name" {
  description = "Name of the VPC and EKS Cluster"
  default     = "kubeflow-test"
  type        = string
}

variable "region" {
  description = "Region"
  default     = "us-east-1"
  type        = string
}

variable "eks_cluster_version" {
  description = "EKS Cluster version"
  type        = string
  default     = "1.27"
}

variable "tags" {
  description = "Default tags"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.1.0.0/16"
}

# Only two Subnets for with low IP range for internet access
variable "public_subnets" {
  description = "Public Subnets CIDRs. 62 IPs per Subnet"
  type        = list(string)
  default     = ["10.1.255.128/26", "10.1.255.192/26"]
}

variable "private_subnets" {
  description = "Private Subnets CIDRs. 32766 Subnet1 and 16382 Subnet2 IPs per Subnet"
  type        = list(string)
  default     = ["10.1.0.0/17", "10.1.128.0/18"]
}

variable "r53_hosted_zones" {
  description = "Hosted Zone ID of an existing Route53 Domain for service discovery"
  type        = list(string)
  default     = ["Z077410331VPQXLL3LC23"]
}