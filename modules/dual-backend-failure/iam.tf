# Create an IAM policy for describing and stopping instances, and accessing S3
resource "aws_iam_policy" "special_instance_policy" {
  name        = "special-instance-policy-${random_pet.fun-name.id}"
  description = "Policy to allow describing and stopping EC2 instances and accessing S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow describing EC2 instances and network interfaces
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces"
        ],
        Resource = "*"
      },
      # Allow stopping specific EC2 instances
      {
        Effect = "Allow"
        Action = "ec2:StopInstances"
        Resource = "arn:aws:ec2:*:*:instance/*" # Allow stopping any instance
      },
      # Allow accessing specific S3 paths
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::cst-scenario-lab",                    # Permission to list the bucket
          "arn:aws:s3:::cst-scenario-lab/weka-installation/*" # Permission to get objects in this path
        ]
      }
    ]
  })
}
