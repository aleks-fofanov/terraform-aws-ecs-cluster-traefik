#############################################################
# Labels
#############################################################

module "default_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"
}

#############################################################
# Common Datasources
#############################################################

data "aws_region" "current" {}

#############################################################
# Locals
#############################################################

locals {
  enable_http_on_alb       = "${var.alb_http_enabled == "true" && var.alb_https_enabled == "true" && var.alb_http_to_https_redirect_enabled == "true" ? "false" : var.alb_http_enabled}"
  redirect_resources_count = "${local.enable_http_on_alb == "false" ? 1 : 0}"
  redirect_code            = "${var.alb_http_to_https_redirect_permanent == "true" ? "302" : "301"}"

  ec2_asg_resources_count = "${var.ec2_asg_enabled == "true" ? 1 : 0}"
  ec2_nat_setup           = "${var.vpc_nat_gateway_enabled == "true" || var.vpc_nat_instance_enabled == "true"}"
}

#############################################################
# VPC
#############################################################

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.4.1"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"

  cidr_block = "${var.vpc_cidr_block}"
}

module "dynamic_subnets" {
  source     = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=0.12.0"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"

  availability_zones      = ["${var.vpc_availability_zones}"]
  vpc_id                  = "${module.vpc.vpc_id}"
  igw_id                  = "${module.vpc.igw_id}"
  cidr_block              = "${var.vpc_cidr_block}"
  nat_gateway_enabled     = "${var.vpc_nat_gateway_enabled}"
  nat_instance_enabled    = "${var.vpc_nat_instance_enabled}"
  nat_instance_type       = "${var.vpc_nat_instance_type}"
  map_public_ip_on_launch = "${var.vpc_map_public_ip_on_launch}"
  max_subnet_count        = "${var.vpc_max_subnet_count}"
}

#############################################################
# ECS Cluster
#############################################################

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 1.4.0"

  name = "${module.default_label.id}"
  tags = "${module.default_label.tags}"
}

#############################################################
# EC2 ASG
#############################################################

data "aws_ami" "amazon_linux_ecs" {
  count = "${local.ec2_asg_resources_count}"

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

locals {
  asg_ec2_userdata = <<USERDATA
#!/bin/bash
# The cluster this agent should check into.
echo 'ECS_CLUSTER=${module.ecs.this_ecs_cluster_name}' >> /etc/ecs/ecs.config
# Disable privileged containers.
echo 'ECS_DISABLE_PRIVILEGED=${var.ecs_disable_privilegged_mode}' >> /etc/ecs/ecs.config
echo 'ECS_AVAILABLE_LOGGING_DRIVERS=["awslogs","fluentd"]' >> /etc/ecs/ecs.config
USERDATA

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html
  vpc_subnets_ids = {
    private = "${module.dynamic_subnets.private_subnet_ids}"
    public  = "${module.dynamic_subnets.public_subnet_ids}"
  }
}

module "ecs_instance_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  attributes = ["${compact(concat(var.attributes, list("ecs","instance")))}"]
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${merge(map("Cluster", "${module.ecs.this_ecs_cluster_name}"), var.tags)}"
}

data "aws_iam_policy_document" "ecs_instance_assume_role_policy" {
  count = "${local.ec2_asg_resources_count}"

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance" {
  count = "${local.ec2_asg_resources_count}"

  name               = "${module.ecs_instance_label.id}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_instance_assume_role_policy.json}"
  path               = "/"

  tags = "${module.ecs_instance_label.tags}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  count = "${local.ec2_asg_resources_count}"

  role       = "${aws_iam_role.ecs_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  count = "${local.ec2_asg_resources_count}"

  name = "${module.ecs_instance_label.id}"
  role = "${aws_iam_role.ecs_instance.name}"
}

resource "aws_security_group" "ecs_instance" {
  count = "${local.ec2_asg_resources_count}"

  name   = "${module.ecs_instance_label.id}"
  vpc_id = "${module.vpc.vpc_id}"

  tags = "${module.ecs_instance_label.tags}"
}

resource "aws_security_group_rule" "ecs_instance_egress" {
  count = "${local.ec2_asg_resources_count}"

  type              = "egress"
  security_group_id = "${aws_security_group.ecs_instance.id}"

  to_port     = "0"
  from_port   = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

module "autoscaling_group" {
  enabled = "${var.ec2_asg_enabled == "true"}"

  source     = "git::https://github.com/cloudposse/terraform-aws-ec2-autoscale-group.git?ref=tags/0.1.3"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${module.ecs_instance_label.tags}"

  security_group_ids = ["${var.ec2_asg_security_group_ids}", "${aws_security_group.ecs_instance.id}"]
  subnet_ids         = "${local.vpc_subnets_ids[local.ec2_nat_setup == "true" ? "private" : "public"]}"

  image_id                             = "${data.aws_ami.amazon_linux_ecs.id}"
  instance_type                        = "${var.ec2_asg_instance_type}"
  instance_initiated_shutdown_behavior = "${var.ec2_asg_instance_initiated_shutdown_behavior}"
  health_check_grace_period            = "${var.ec2_asg_health_check_grace_period}"
  health_check_type                    = "${var.ec2_asg_health_check_type}"
  key_name                             = "${var.ec2_asg_key_name}"
  placement_group                      = "${var.ec2_asg_placement_group}"
  iam_instance_profile_name            = "${aws_iam_instance_profile.ecs_instance.name}"
  service_linked_role_arn              = "${var.ec2_asg_service_linked_role_arn}"
  associate_public_ip_address          = "${local.ec2_nat_setup == "true" ? "false" : "true"}"
  user_data_base64                     = "${base64encode(local.asg_ec2_userdata)}"

  ebs_optimized         = "${var.ec2_asg_ebs_optimized}"
  block_device_mappings = "${var.ec2_asg_block_device_mappings}"

  instance_market_options    = "${var.ec2_asg_instance_market_options}"
  placement                  = "${var.ec2_asg_placement}"
  credit_specification       = "${var.ec2_asg_credit_specification}"
  elastic_gpu_specifications = "${var.ec2_asg_elastic_gpu_specifications}"

  disable_api_termination = "${var.ec2_asg_disable_api_termination}"
  termination_policies    = "${var.ec2_asg_termination_policies}"
  force_delete            = "${var.ec2_asg_force_delete}"
  suspended_processes     = "${var.ec2_asg_suspended_processes}"

  min_size                  = "${var.ec2_asg_autoscaling_min_capacity}"
  max_size                  = "${var.ec2_asg_autoscaling_max_capacity}"
  wait_for_capacity_timeout = "${var.ec2_asg_wait_for_capacity_timeout}"
  default_cooldown          = "${var.ec2_asg_default_cooldown}"
  protect_from_scale_in     = "${var.ec2_asg_protect_from_scale_in}"

  enable_monitoring   = "${var.ec2_asg_enable_monitoring}"
  enabled_metrics     = "${var.ec2_asg_enabled_metrics}"
  metrics_granularity = "${var.ec2_asg_metrics_granularity}"

  autoscaling_policies_enabled            = "${var.ec2_asg_autoscaling_policies_enabled}"
  scale_up_cooldown_seconds               = "${var.ec2_asg_autoscaling_scale_up_cooldown_seconds}"
  scale_up_scaling_adjustment             = "${var.ec2_asg_autoscaling_scale_up_scaling_adjustment}"
  scale_up_adjustment_type                = "${var.ec2_asg_autoscaling_scale_up_adjustment_type}"
  scale_up_policy_type                    = "${var.ec2_asg_autoscaling_scale_up_policy_type}"
  scale_down_cooldown_seconds             = "${var.ec2_asg_autoscaling_scale_down_cooldown_seconds}"
  scale_down_scaling_adjustment           = "${var.ec2_asg_autoscaling_scale_down_scaling_adjustment}"
  scale_down_adjustment_type              = "${var.ec2_asg_autoscaling_scale_down_adjustment_type}"
  scale_down_policy_type                  = "${var.ec2_asg_autoscaling_scale_down_policy_type}"
  cpu_utilization_high_evaluation_periods = "${var.ec2_asg_autoscaling_cpu_utilization_high_evaluation_periods}"
  cpu_utilization_high_period_seconds     = "${var.ec2_asg_autoscaling_cpu_utilization_high_period_seconds}"
  cpu_utilization_high_threshold_percent  = "${var.ec2_asg_autoscaling_cpu_utilization_high_threshold_percent}"
  cpu_utilization_high_statistic          = "${var.ec2_asg_autoscaling_cpu_utilization_high_statistic}"
  cpu_utilization_low_evaluation_periods  = "${var.ec2_asg_autoscaling_cpu_utilization_low_evaluation_periods}"
  cpu_utilization_low_period_seconds      = "${var.ec2_asg_autoscaling_cpu_utilization_low_period_seconds}"
  cpu_utilization_low_threshold_percent   = "${var.ec2_asg_autoscaling_cpu_utilization_low_threshold_percent}"
  cpu_utilization_low_statistic           = "${var.ec2_asg_autoscaling_cpu_utilization_low_statistic}"
}

#############################################################
# ALB
#############################################################

module "alb" {
  source     = "git::https://github.com/cloudposse/terraform-aws-alb.git?ref=tags/0.5.0"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"

  vpc_id             = "${module.vpc.vpc_id}"
  subnet_ids         = "${module.dynamic_subnets.public_subnet_ids}"
  security_group_ids = "${var.alb_security_group_ids}"
  certificate_arn    = "${var.alb_certificate_arn}"

  internal                          = "false"
  ip_address_type                   = "ipv4"
  cross_zone_load_balancing_enabled = "true"
  target_group_port                 = "${var.traefik_container_http_port}"
  idle_timeout                      = "${var.alb_idle_timeout}"
  deletion_protection_enabled       = "${var.alb_deletion_protection_enabled}"

  http_enabled                 = "${local.enable_http_on_alb}"
  http_port                    = "${var.alb_http_port}"
  http_ingress_cidr_blocks     = "${var.alb_http_ingress_cidr_blocks}"
  http_ingress_prefix_list_ids = "${var.alb_http_ingress_prefix_list_ids}"

  https_enabled                 = "${var.alb_https_enabled}"
  https_port                    = "${var.alb_https_port}"
  https_ingress_cidr_blocks     = "${var.alb_https_ingress_cidr_blocks}"
  https_ingress_prefix_list_ids = "${var.alb_https_ingress_prefix_list_ids}"
  https_ssl_policy              = "${var.alb_https_ssl_policy}"

  http2_enabled = "${var.alb_http2_enabled}"

  # Traefik ping endpoint
  health_check_path                = "/ping"
  health_check_timeout             = "10"
  health_check_healthy_threshold   = "2"
  health_check_unhealthy_threshold = "2"
  health_check_interval            = "15"

  access_logs_enabled                     = "${var.alb_access_logs_enabled}"
  access_logs_region                      = "${var.alb_access_logs_region}"
  access_logs_prefix                      = "${var.alb_access_logs_prefix}"
  alb_access_logs_s3_bucket_force_destroy = "${var.alb_access_logs_s3_bucket_force_destroy}"
}

resource "aws_lb_listener" "http_to_https_redirect" {
  count = "${local.redirect_resources_count}"

  load_balancer_arn = "${module.alb.alb_arn}"
  port              = "${var.alb_http_port}"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "${var.alb_https_port}"
      protocol    = "HTTPS"
      status_code = "HTTP_${local.redirect_code}"
    }
  }
}

resource "aws_security_group_rule" "http_ingress" {
  count = "${local.redirect_resources_count}"

  type              = "ingress"
  from_port         = "${var.alb_http_port}"
  to_port           = "${var.alb_http_port}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.alb_http_ingress_cidr_blocks}"]
  prefix_list_ids   = ["${var.alb_http_ingress_prefix_list_ids}"]
  security_group_id = "${module.alb.security_group_id}"
}

# The following data source is required to wait for ALB will to be
# fully provisioned before creating ECS Service for ABL Target Group

data "aws_alb_target_group" "default" {
  arn = "${module.alb.default_target_group_arn}"
}

module "alb_target_group_alarms" {
  enabled = "${var.alb_target_group_alarms_enabled}"

  source     = "git::https://github.com/cloudposse/terraform-aws-alb-target-group-cloudwatch-sns-alarms.git?ref=tags/0.5.0"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"

  alb_name                       = "${module.alb.alb_name}"
  alb_arn_suffix                 = "${module.alb.alb_arn_suffix}"
  target_group_name              = "${data.aws_alb_target_group.default.name}"
  target_group_arn_suffix        = "${data.aws_alb_target_group.default.arn_suffix}"
  target_3xx_count_threshold     = "${var.alb_target_group_alarms_3xx_threshold}"
  target_4xx_count_threshold     = "${var.alb_target_group_alarms_4xx_threshold}"
  target_5xx_count_threshold     = "${var.alb_target_group_alarms_5xx_threshold}"
  target_response_time_threshold = "${var.alb_target_group_alarms_response_time_threshold}"
  period                         = "${var.alb_target_group_alarms_period}"
  evaluation_periods             = "${var.alb_target_group_alarms_evaluation_periods}"

  ok_actions                = "${var.alb_target_group_alarms_ok_actions}"
  alarm_actions             = "${var.alb_target_group_alarms_alarm_actions}"
  insufficient_data_actions = "${var.alb_target_group_alarms_insufficient_data_actions}"
}

#############################################################
# Traefik
#############################################################

data "aws_alb_target_group" "traefik" {
  depends_on = ["module.alb"]

  arn = "${module.alb.default_target_group_arn}"
}

module "traefik" {
  source     = "git::https://github.com/aleks-fofanov/terraform-aws-ecs-traefik-service.git?ref=tags/0.1.1"
  attributes = ["${compact(concat(var.attributes, list("traefik")))}"]
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"

  ecs_cluster_name      = "${module.ecs.this_ecs_cluster_name}"
  ecs_cluster_arn       = "${module.ecs.this_ecs_cluster_arn}"
  ecs_cluster_region    = "${data.aws_region.current.name}"
  alb_security_group_id = "${module.alb.security_group_id}"
  alb_target_group_arn  = "${data.aws_alb_target_group.traefik.arn}"
  vpc_id                = "${module.vpc.vpc_id}"
  subnet_ids            = "${module.dynamic_subnets.public_subnet_ids}"

  launch_type      = "${var.traefik_launch_type}"
  assign_public_ip = "${var.traefik_assign_public_ip}"

  container_name          = "${var.traefik_container_name}"
  task_image              = "${var.traefik_task_image}"
  task_cpu                = "${var.traefik_task_cpu}"
  task_memory             = "${var.traefik_task_memory}"
  task_memory_reservation = "${var.traefik_task_memory_reservation}"
  log_level               = "${var.traefik_log_level}"
  log_format              = "${var.traefik_log_format}"
  logs_retention          = "${var.traefik_logs_retention}"
  logs_region             = "${var.traefik_logs_region}"

  http_port = "${var.traefik_container_http_port}"

  dashboard_enabled             = "${var.traefik_dashboard_enabled}"
  dashboard_host                = "${var.traefik_dashboard_host}"
  dashboard_basic_auth_user     = "${var.traefik_dashboard_basic_auth_user}"
  dashboard_basic_auth_password = "${var.traefik_dashboard_basic_auth_password}"

  desired_count                      = "${var.traefik_desired_count}"
  deployment_controller_type         = "${var.traefik_deployment_controller_type}"
  deployment_maximum_percent         = "${var.traefik_deployment_maximum_percent}"
  deployment_minimum_healthy_percent = "${var.traefik_deployment_minimum_healthy_percent}"

  mount_points = "${var.traefik_mount_points}"
  volumes      = "${var.traefik_volumes}"

  ignore_changes_task_definition = "${var.traefik_ignore_changes_task_definition}"

  autoscaling_enabled = "${var.traefik_autoscaling_enabled}"

  autoscaling_dimension             = "${var.traefik_autoscaling_dimension}"
  autoscaling_min_capacity          = "${var.traefik_autoscaling_min_capacity}"
  autoscaling_max_capacity          = "${var.traefik_autoscaling_max_capacity}"
  autoscaling_scale_up_adjustment   = "${var.traefik_autoscaling_scale_up_adjustment}"
  autoscaling_scale_up_cooldown     = "${var.traefik_autoscaling_scale_up_cooldown}"
  autoscaling_scale_down_adjustment = "${var.traefik_autoscaling_scale_down_adjustment}"
  autoscaling_scale_down_cooldown   = "${var.traefik_autoscaling_scale_down_cooldown}"

  ecs_alarms_enabled = "${var.traefik_ecs_alarms_enabled}"

  ecs_alarms_cpu_utilization_high_threshold          = "${var.traefik_ecs_alarms_cpu_utilization_high_threshold}"
  ecs_alarms_cpu_utilization_high_evaluation_periods = "${var.traefik_ecs_alarms_cpu_utilization_high_evaluation_periods}"
  ecs_alarms_cpu_utilization_high_period             = "${var.traefik_ecs_alarms_cpu_utilization_high_period}"
  ecs_alarms_cpu_utilization_high_alarm_actions      = "${var.traefik_ecs_alarms_cpu_utilization_high_alarm_actions}"
  ecs_alarms_cpu_utilization_high_ok_actions         = "${var.traefik_ecs_alarms_cpu_utilization_high_ok_actions}"
  ecs_alarms_cpu_utilization_low_threshold           = "${var.traefik_ecs_alarms_cpu_utilization_low_threshold}"
  ecs_alarms_cpu_utilization_low_evaluation_periods  = "${var.traefik_ecs_alarms_cpu_utilization_low_evaluation_periods}"
  ecs_alarms_cpu_utilization_low_period              = "${var.traefik_ecs_alarms_cpu_utilization_low_period}"
  ecs_alarms_cpu_utilization_low_alarm_actions       = "${var.traefik_ecs_alarms_cpu_utilization_low_alarm_actions}"
  ecs_alarms_cpu_utilization_low_ok_actions          = "${var.traefik_ecs_alarms_cpu_utilization_low_ok_actions}"

  ecs_alarms_memory_utilization_high_threshold          = "${var.traefik_ecs_alarms_memory_utilization_high_threshold}"
  ecs_alarms_memory_utilization_high_evaluation_periods = "${var.traefik_ecs_alarms_memory_utilization_high_evaluation_periods}"
  ecs_alarms_memory_utilization_high_period             = "${var.traefik_ecs_alarms_memory_utilization_high_period}"
  ecs_alarms_memory_utilization_high_alarm_actions      = "${var.traefik_ecs_alarms_memory_utilization_high_alarm_actions}"
  ecs_alarms_memory_utilization_high_ok_actions         = "${var.traefik_ecs_alarms_memory_utilization_high_ok_actions}"
  ecs_alarms_memory_utilization_low_threshold           = "${var.traefik_ecs_alarms_memory_utilization_low_threshold}"
  ecs_alarms_memory_utilization_low_evaluation_periods  = "${var.traefik_ecs_alarms_memory_utilization_low_evaluation_periods}"
  ecs_alarms_memory_utilization_low_period              = "${var.traefik_ecs_alarms_memory_utilization_low_period}"
  ecs_alarms_memory_utilization_low_alarm_actions       = "${var.traefik_ecs_alarms_memory_utilization_low_alarm_actions}"
  ecs_alarms_memory_utilization_low_ok_actions          = "${var.traefik_ecs_alarms_memory_utilization_low_ok_actions}"
}
