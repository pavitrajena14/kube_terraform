output "EKS_CLUSTER_NAME" {
    value = aws_eks_cluster.eks_cluster.id
}
output "EKS_CLUSTER_ENDPOINT" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "EKS_CLUSTER_CA" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "EKS_CLUSTER_CIDR" {
  value = aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr
}
