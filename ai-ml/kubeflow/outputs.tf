################################################################################
# EKS Managed Node Group
################################################################################

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

################################################################################
# AMP
################################################################################
output "get_grafana_password" {
  description = "Run this command to retrieve the grafana password for dashboard login"
  value       = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.grafana.name} --region us-east-1 --query 'SecretString' --output text"
}