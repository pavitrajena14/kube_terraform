data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/1.34/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

resource "aws_launch_template" "node_group_lt" {
  name_prefix   = "${var.EKS_CLUSTER_NAME}-lt-"
  image_id      = data.aws_ssm_parameter.eks_ami.value
  instance_type = "t3.micro"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }

  user_data = base64encode(<<-EOT
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="BOUNDARY"

    --BOUNDARY
    Content-Type: application/node.eks.aws

    ---
    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      cluster:
        name: ${var.EKS_CLUSTER_NAME}
        apiServerEndpoint: ${var.CLUSTER_ENDPOINT}
        certificateAuthority: ${var.CLUSTER_CA}
        cidr: ${var.CLUSTER_CIDR}
      kubelet:
        flags:
          - "--max-pods=110"

    --BOUNDARY--
  EOT
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.EKS_CLUSTER_NAME
  node_group_name = "${var.EKS_CLUSTER_NAME}-node_group"
  node_role_arn   = var.NODE_GROUP_ARN

  subnet_ids = [
    var.PRI_SUB3_ID,
    var.PRI_SUB4_ID
  ]

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }

  launch_template {
    id      = aws_launch_template.node_group_lt.id
    version = "$Latest"
  }

  capacity_type        = "ON_DEMAND"
  force_update_version = false

  labels = {
    role = "${var.EKS_CLUSTER_NAME}-Node-group-role"
    name = "${var.EKS_CLUSTER_NAME}-node_group"
  }

  lifecycle {
    create_before_destroy = true
  }
}
