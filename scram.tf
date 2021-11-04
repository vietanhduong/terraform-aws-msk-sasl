resource "random_string" "this" {
  length  = 7
  special = false
}

resource "aws_kms_key" "sasl_user" {
  description = "SASL User key for ${var.cluster_name} MSK Cluster Scram Secret Association"
}

resource "aws_secretsmanager_secret" "sasl_user" {
  name       = "AmazonMSK_${var.sasl_username}_${random_string.this.result}"
  kms_key_id = aws_kms_key.sasl_user.key_id
}

resource "aws_secretsmanager_secret_version" "sasl_user" {
  secret_id     = aws_secretsmanager_secret.sasl_user.id
  secret_string = jsonencode({ username = var.sasl_username, password = var.sasl_password })
}

data "aws_iam_policy_document" "sasl_user" {
  version = "2012-10-17"

  statement {
    sid       = "AWSKafkaResourcePolicy"
    actions   = ["secretsmanager:getSecretValue"]
    resources = [aws_secretsmanager_secret.sasl_user.arn]
    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_secretsmanager_secret_policy" "sasl_user" {
  secret_arn = aws_secretsmanager_secret.sasl_user.arn
  policy     = data.aws_iam_policy_document.sasl_user.json
}

resource "aws_msk_scram_secret_association" "sasl_user" {
  cluster_arn     = aws_msk_cluster.this.arn
  secret_arn_list = [aws_secretsmanager_secret.sasl_user.arn]

  depends_on = [aws_secretsmanager_secret_version.sasl_user]
}
