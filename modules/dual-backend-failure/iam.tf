# Create an IAM role with a unique name
resource "aws_iam_role" "ec2_instance_role_special" {
  name = "ec2-instance-role-special-${var.random_pet_id}" # Use var.random_pet_id to make it unique

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create an IAM policy for describing and stopping instances, and accessing S3
resource "aws_iam_policy" "special_instance_policy" {
  name        = "special-instance-policy-${var.random_pet_id}"
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

# Attach the special policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_special_instance_policy" {
  role       = aws_iam_role.ec2_instance_role_special.name
  policy_arn = aws_iam_policy.special_instance_policy.arn
}

# Create an instance profile with the special IAM role
resource "aws_iam_instance_profile" "ec2_instance_profile_special" {
  name = "ec2-instance-profile-special-${var.random_pet_id}"
  role = aws_iam_role.ec2_instance_role_special.name
}
