output "vpc_igw_id" {
  value       = module.vpc.igw_id
  description = "The ID of the Internet Gateway"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "The CIDR block of the VPC"
}

output "vpc_main_route_table_id" {
  value       = module.vpc.vpc_main_route_table_id
  description = "The ID of the main route table associated with this VPC."
}

output "vpc_default_network_acl_id" {
  value       = module.vpc.vpc_default_network_acl_id
  description = "The ID of the network ACL created by default on VPC creation"
}

output "vpc_default_security_group_id" {
  value       = module.vpc.vpc_default_security_group_id
  description = "The ID of the security group created by default on VPC creation"
}

output "vpc_default_route_table_id" {
  value       = module.vpc.vpc_default_route_table_id
  description = "The ID of the route table created by default on VPC creation"
}

output "vpc_public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = module.dynamic_subnets.public_subnet_ids
}

output "vpc_private_subnet_ids" {
  description = "IDs of the created private subnets"
  value       = module.dynamic_subnets.private_subnet_ids
}

output "vpc_public_subnet_cidrs" {
  description = "CIDR blocks of the created public subnets"
  value       = module.dynamic_subnets.public_subnet_cidrs
}

output "vpc_private_subnet_cidrs" {
  description = "CIDR blocks of the created private subnets"
  value       = module.dynamic_subnets.private_subnet_cidrs
}

output "vpc_public_route_table_ids" {
  description = "IDs of the created public route tables"
  value       = module.dynamic_subnets.public_route_table_ids
}

output "vpc_private_route_table_ids" {
  description = "IDs of the created private route tables"
  value       = module.dynamic_subnets.private_route_table_ids
}

output "vpc_nat_gateway_ids" {
  description = "IDs of the NAT Gateways created"
  value       = module.dynamic_subnets.nat_gateway_ids
}

output "vpc_nat_instance_ids" {
  description = "IDs of the NAT Instances created"
  value       = module.dynamic_subnets.nat_instance_ids
}

output "vpc_availability_zones" {
  description = "List of Availability Zones where subnets were created"
  value       = module.dynamic_subnets.availability_zones
}

output "ecs_cluster_id" {
  value       = module.ecs.this_ecs_cluster_id
  description = "Id of ECS cluster"
}

output "ecs_cluster_name" {
  value       = module.ecs.this_ecs_cluster_name
  description = "Name of ECS cluster"
}

output "ecs_cluster_arn" {
  value       = module.ecs.this_ecs_cluster_arn
  description = "ARN of ECS cluster"
}

output "ec2_instance_role_arn" {
  value       = join("", aws_iam_role.ecs_instance.*.arn)
  description = "ARN of IAM role assumed by ECS cluster instances launched in EC2 ASG"
}

output "ec2_instance_role_name" {
  value       = join("", aws_iam_role.ecs_instance.*.name)
  description = "Name of IAM role assumed by ECS cluster instances launched in EC2 ASG"
}

output "ec2_instance_profile_name" {
  value       = join("", aws_iam_instance_profile.ecs_instance.*.name)
  description = "Name of instance profile used with ECS cluster instances launched in EC2 ASG"
}

output "ec2_instance_profile_arn" {
  value       = join("", aws_iam_instance_profile.ecs_instance.*.arn)
  description = "ARN of instance profile used with ECS cluster instances launched in EC2 ASG"
}

output "ec2_instance_security_group_id" {
  value       = join("", aws_security_group.ecs_instance.*.id)
  description = "Id of secufity group associated with ECS cluster instances launched in EC2 ASG"
}

output "ec2_launch_template_id" {
  description = "The ID of the launch template"
  value       = module.autoscaling_group.launch_template_id
}

output "ec2_launch_template_arn" {
  description = "The ARN of the launch template"
  value       = module.autoscaling_group.launch_template_arn
}

output "ec2_autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.autoscaling_group.autoscaling_group_id
}

output "ec2_autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = module.autoscaling_group.autoscaling_group_name
}

output "ec2_autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.autoscaling_group.autoscaling_group_arn
}

output "alb_name" {
  description = "The name of the ALB"
  value       = module.alb.alb_name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = module.alb.alb_arn
}

output "alb_arn_suffix" {
  description = "The ARN suffix of the ALB"
  value       = module.alb.alb_arn_suffix
}

output "alb_dns_name" {
  description = "DNS name of ALB"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "The ID of the zone which ALB is provisioned"
  value       = module.alb.alb_zone_id
}

output "alb_security_group_id" {
  description = "The security group ID of the ALB"
  value       = module.alb.security_group_id
}

output "alb_default_target_group_arn" {
  description = "The default target group ARN"
  value       = module.alb.default_target_group_arn
}

output "alb_http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = module.alb.http_listener_arn
}

output "alb_https_listener_arn" {
  description = "The ARN of the HTTPS listener"
  value       = module.alb.https_listener_arn
}

output "alb_listener_arns" {
  description = "A list of all the listener ARNs"
  value       = module.alb.listener_arns
}

output "alb_access_logs_bucket_id" {
  description = "The S3 bucket ID for access logs"
  value       = module.alb.access_logs_bucket_id
}

output "traefik_ecs_exec_role_policy_id" {
  description = "The ECS service role policy ID, in the form of role_name:role_policy_name"
  value       = module.traefik.ecs_exec_role_policy_id
}

output "traefik_ecs_exec_role_policy_name" {
  description = "ECS service role name"
  value       = module.traefik.ecs_exec_role_policy_name
}

output "traefik_service_name" {
  description = "ECS Service name"
  value       = module.traefik.service_name
}

output "traefik_service_role_arn" {
  description = "ECS Service role ARN"
  value       = module.traefik.service_role_arn
}

output "traefik_task_exec_role_name" {
  description = "ECS Task role name"
  value       = module.traefik.task_exec_role_name
}

output "traefik_task_exec_role_arn" {
  description = "ECS Task exec role ARN"
  value       = module.traefik.task_exec_role_arn
}

output "traefik_task_role_name" {
  description = "ECS Task role name"
  value       = module.traefik.task_role_name
}

output "traefik_task_role_arn" {
  description = "ECS Task role ARN"
  value       = module.traefik.task_role_arn
}

output "traefik_task_role_id" {
  description = "ECS Task role id"
  value       = module.traefik.task_role_id
}

output "traefik_service_security_group_id" {
  description = "Security Group ID of the ECS task"
  value       = module.traefik.service_security_group_id
}

output "traefik_task_definition_family" {
  description = "ECS task definition family"
  value       = module.traefik.task_definition_family
}

output "traefik_task_definition_revision" {
  description = "ECS task definition revision"
  value       = module.traefik.task_definition_revision
}

output "traefik_scale_down_policy_arn" {
  description = "Autoscaling scale up policy ARN"
  value       = module.traefik.scale_down_policy_arn
}

output "traefik_scale_up_policy_arn" {
  description = "Autoscaling scale up policy ARN"
  value       = module.traefik.scale_up_policy_arn
}
