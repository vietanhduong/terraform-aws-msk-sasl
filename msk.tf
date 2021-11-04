resource "aws_kms_key" "msk_key" {
  description = "${var.cluster_name}'s MSK Cluster Key"
}

resource "aws_cloudwatch_log_group" "this" {
  name = "${var.cluster_name}_broker_logs"
}

resource "aws_msk_configuration" "this" {
  kafka_versions    = [var.kafka_version]
  count             = length(var.cluster_config) > 0 ? 1 : 0
  name              = "${var.cluster_name}-config"
  server_properties = <<PROPERTIES
${join("\n", var.cluster_config)}
PROPERTIES
}

resource "aws_security_group" "msk_sg" {
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_msk_cluster" "this" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = length(local.private_subnet_ids) * var.broker_count

  broker_node_group_info {
    instance_type   = var.broker_type
    ebs_volume_size = var.broker_volume_size
    client_subnets  = local.private_subnet_ids
    security_groups = [aws_security_group.msk_sg.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.msk_key.arn
  }

  client_authentication {
    sasl {
      scram = true
    }
  }

  dynamic "configuration_info" {
    for_each = length(var.cluster_config) > 0 ? [1] : []

    content {
      arn      = aws_msk_configuration.this.0.arn
      revision = aws_msk_configuration.this.0.latest_revision
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }

      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.this.name
      }
    }
  }
}
