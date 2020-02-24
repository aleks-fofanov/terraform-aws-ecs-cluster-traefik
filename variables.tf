variable "namespace" {
  type        = string
  description = "Namespace (e.g. `cp` or `cloudposse`)"
  default     = "cp"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  default     = "prod"
}

variable "name" {
  type        = string
  default     = "traefik"
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `name`, `stage` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes, e.g. `1`"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map(`BusinessUnit`,`XYZ`)"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.10.0.0/16"
  description = "VPC CIDR block"
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "List of Availability Zones where subnets will be created"
}

variable "vpc_nat_gateway_enabled" {
  type        = bool
  default     = true
  description = "Flag to enable/disable NAT Gateways to allow servers in the private subnets to access the Internet"
}

variable "vpc_nat_instance_enabled" {
  type        = bool
  default     = false
  description = "Flag to enable/disable NAT Instances to allow servers in the private subnets to access the Internet"
}

variable "vpc_nat_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "NAT Instance type"
}

variable "vpc_map_public_ip_on_launch" {
  type        = bool
  default     = true
  description = "Instances launched into a public subnet should be assigned a public IP address"
}

variable "vpc_max_subnet_count" {
  type        = number
  default     = 0
  description = "Sets the maximum amount of subnets to deploy. 0 will deploy a subnet for every provided availablility zone (in availability_zones variable) within the region"
}

variable "ec2_asg_enabled" {
  type        = bool
  default     = false
  description = "Defines whether autoscaling EC2 instance group should be provisioned for a ECS cluster"
}

variable "ec2_asg_instance_type" {
  type        = string
  description = "Instance type to launch"
  default     = "t3.micro"
}

variable "ec2_asg_instance_initiated_shutdown_behavior" {
  type        = string
  description = "Shutdown behavior for the instances in ASG. Can be `stop` or `terminate`"
  default     = "terminate"
}

variable "ec2_asg_key_name" {
  type        = string
  description = "The SSH key name that should be used for the instances in ASG"
  default     = ""
}

variable "ec2_asg_security_group_ids" {
  description = "A list of security group IDs to be associated with instances in ASG"
  type        = list(string)
  default     = []
}

variable "ec2_asg_enable_monitoring" {
  description = "Enable/disable detailed monitoring of the instanes in ASG"
  default     = true
  type        = bool
}

variable "ec2_asg_ebs_optimized" {
  description = "If true, the launched EC2 instances in ASG will be EBS-optimized"
  default     = false
  type        = bool
}

variable "ec2_asg_block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"

  type = list(object({
    device_name  = string
    no_device    = bool
    virtual_name = string
    ebs = object({
      delete_on_termination = bool
      encrypted             = bool
      iops                  = number
      kms_key_id            = string
      snapshot_id           = string
      volume_size           = number
      volume_type           = string
    })
  }))

  default = []
}

variable "ec2_asg_instance_market_options" {
  description = "The market (purchasing) option for the instances"

  type = object({
    market_type = string
    spot_options = object({
      block_duration_minutes         = number
      instance_interruption_behavior = string
      max_price                      = number
      spot_instance_type             = string
      valid_until                    = string
    })
  })

  default = null
}

variable "ec2_asg_placement" {
  description = "The placement specifications of the instances"

  type = object({
    affinity          = string
    availability_zone = string
    group_name        = string
    host_id           = string
    tenancy           = string
  })

  default = null
}

variable "ec2_asg_credit_specification" {
  description = "Customize the credit specification of the instances"

  type = object({
    cpu_credits = string
  })

  default = null
}

variable "ec2_asg_elastic_gpu_specifications" {
  description = "Specifications of Elastic GPU to attach to the instances"

  type = object({
    type = string
  })

  default = null
}

variable "ec2_asg_disable_api_termination" {
  description = "If `true`, enables EC2 Instance Termination Protection for instances in ASG"
  default     = false
  type        = bool
}

variable "ec2_asg_default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  default     = 300
  type        = number
}

variable "ec2_asg_health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  default     = 300
  type        = number
}

variable "ec2_asg_health_check_type" {
  type        = string
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`"
  default     = "EC2"
}

variable "ec2_asg_force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling"
  default     = false
  type        = bool
}

variable "ec2_asg_termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default`"
  type        = list(string)
  default     = ["Default"]
}

variable "ec2_asg_suspended_processes" {
  type        = list(string)
  description = "A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your autoscaling group from functioning properly."
  default     = []
}

variable "ec2_asg_placement_group" {
  type        = string
  description = "The name of the placement group into which you'll launch your instances, if any"
  default     = ""
}

variable "ec2_asg_metrics_granularity" {
  type        = string
  description = "The granularity to associate with the metrics to collect. The only valid value is 1Minute"
  default     = "1Minute"
}

variable "ec2_asg_enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are `GroupMinSize`, `GroupMaxSize`, `GroupDesiredCapacity`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupTerminatingInstances`, `GroupTotalInstances`"
  type        = list(string)

  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "ec2_asg_wait_for_capacity_timeout" {
  type        = string
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior"
  default     = "10m"
}

variable "ec2_asg_protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events"
  default     = false
  type        = bool
}

variable "ec2_asg_service_linked_role_arn" {
  type        = string
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services"
  default     = ""
}

variable "ec2_asg_autoscaling_policies_enabled" {
  type        = bool
  default     = true
  description = "Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling"
}

variable "ec2_asg_autoscaling_min_capacity" {
  type        = number
  description = "Minimum number of running EC2 instances in ASG"
  default     = 2
}

variable "ec2_asg_autoscaling_max_capacity" {
  type        = number
  description = "Maximum number of running EC2 instances in ASG"
  default     = 3
}

variable "ec2_asg_autoscaling_scale_up_cooldown_seconds" {
  type        = number
  default     = 300
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start"
}

variable "ec2_asg_autoscaling_scale_up_scaling_adjustment" {
  type        = number
  default     = 1
  description = "The number of instances by which to scale. `scale_up_adjustment_type` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity"
}

variable "ec2_asg_autoscaling_scale_up_adjustment_type" {
  type        = string
  default     = "ChangeInCapacity"
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity`"
}

variable "ec2_asg_autoscaling_scale_up_policy_type" {
  type        = string
  default     = "SimpleScaling"
  description = "The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling`"
}

variable "ec2_asg_autoscaling_scale_down_cooldown_seconds" {
  type        = number
  default     = 300
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start"
}

variable "ec2_asg_autoscaling_scale_down_scaling_adjustment" {
  type        = number
  default     = -1
  description = "The number of instances by which to scale. `scale_down_scaling_adjustment` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity"
}

variable "ec2_asg_autoscaling_scale_down_adjustment_type" {
  type        = string
  default     = "ChangeInCapacity"
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity`"
}

variable "ec2_asg_autoscaling_scale_down_policy_type" {
  type        = string
  default     = "SimpleScaling"
  description = "The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling`"
}

variable "ec2_asg_autoscaling_cpu_utilization_high_evaluation_periods" {
  type        = number
  default     = 2
  description = "The number of periods over which data is compared to the specified threshold"
}

variable "ec2_asg_autoscaling_cpu_utilization_high_period_seconds" {
  type        = number
  default     = 300
  description = "The period in seconds over which the specified statistic is applied"
}

variable "ec2_asg_autoscaling_cpu_utilization_high_threshold_percent" {
  type        = number
  default     = 90
  description = "The value against which the specified statistic is compared"
}

variable "ec2_asg_autoscaling_cpu_utilization_high_statistic" {
  type        = string
  default     = "Average"
  description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum`"
}

variable "ec2_asg_autoscaling_cpu_utilization_low_evaluation_periods" {
  type        = number
  default     = 2
  description = "The number of periods over which data is compared to the specified threshold"
}

variable "ec2_asg_autoscaling_cpu_utilization_low_period_seconds" {
  type        = number
  default     = 300
  description = "The period in seconds over which the specified statistic is applied"
}

variable "ec2_asg_autoscaling_cpu_utilization_low_threshold_percent" {
  type        = number
  default     = 10
  description = "The value against which the specified statistic is compared"
}

variable "ec2_asg_autoscaling_cpu_utilization_low_statistic" {
  type        = string
  default     = "Average"
  description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum`"
}

variable "ecs_disable_privilegged_mode" {
  type        = bool
  default     = true
  description = "Defines whether privilegged mode should be disabed for containers running with launch type EC2"
}

variable "alb_security_group_ids" {
  type        = list(string)
  default     = []
  description = "A list of additional security group IDs to allow access to ALB"
}

variable "alb_http_port" {
  type        = number
  default     = 80
  description = "The port for the HTTP listener"
}

variable "alb_http_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable HTTP listener"
}

variable "alb_http_ingress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks to allow in HTTP security group"
}

variable "alb_http_ingress_prefix_list_ids" {
  type        = list(string)
  default     = []
  description = "List of prefix list IDs for allowing access to HTTP ingress security group"
}

variable "alb_certificate_arn" {
  type        = string
  default     = ""
  description = "The ARN of the default SSL certificate for HTTPS listener"
}

variable "alb_https_port" {
  type        = number
  default     = 443
  description = "The port for the HTTPS listener"
}

variable "alb_https_enabled" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable HTTPS listener"
}

variable "alb_https_ingress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks to allow in HTTPS security group"
}

variable "alb_https_ingress_prefix_list_ids" {
  type        = list(string)
  default     = []
  description = "List of prefix list IDs for allowing access to HTTPS ingress security group"
}

variable "alb_https_ssl_policy" {
  description = "The name of the SSL Policy for the listener. See https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
  type        = string
}

variable "alb_http_to_https_redirect_enabled" {
  type        = bool
  default     = true
  description = "Defines whether HTTP traffic should be redirected to HTTPS on ALB"
}

variable "alb_http_to_https_redirect_permanent" {
  type        = bool
  default     = true
  description = "Defines whether HTTP to HTTPS redirect on ALB should be permanent (i.e. return 301 or 302 HTTP code)."
}

variable "alb_http2_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable HTTP/2"
}

variable "alb_access_logs_prefix" {
  type        = string
  default     = ""
  description = "The S3 bucket prefix"
}

variable "alb_access_logs_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable access_logs"
}

variable "alb_access_logs_region" {
  type        = string
  default     = "us-east-1"
  description = "The region for the access_logs S3 bucket"
}

variable "alb_access_logs_s3_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the ALB access logs S3 bucket so that the bucket can be destroyed without error"
  default     = false
  type        = bool
}

variable "alb_idle_timeout" {
  type        = number
  default     = 60
  description = "The time in seconds that the connection is allowed to be idle"
}

variable "alb_deletion_protection_enabled" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable deletion protection for ALB"
}

variable "alb_target_group_alarms_enabled" {
  type        = bool
  description = "A boolean to enable/disable CloudWatch Alarms for ALB Target metrics"
  default     = false
}

variable "alb_target_group_alarms_3xx_threshold" {
  type        = number
  description = "The maximum number of 3XX HTTPCodes in a given period for ECS Service"
  default     = 25
}

variable "alb_target_group_alarms_4xx_threshold" {
  type        = number
  description = "The maximum number of 4XX HTTPCodes in a given period for ECS Service"
  default     = 25
}

variable "alb_target_group_alarms_5xx_threshold" {
  type        = number
  description = "The maximum number of 5XX HTTPCodes in a given period for ECS Service"
  default     = 25
}

variable "alb_target_group_alarms_response_time_threshold" {
  type        = number
  description = "The maximum ALB Target Group response time"
  default     = 0.5
}

variable "alb_target_group_alarms_period" {
  type        = number
  description = "The period (in seconds) to analyze for ALB CloudWatch Alarms"
  default     = 300
}

variable "alb_target_group_alarms_evaluation_periods" {
  type        = number
  description = "The number of periods to analyze for ALB CloudWatch Alarms"
  default     = 1
}

variable "alb_target_group_alarms_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to execute when ALB Target Group alarms transition into an ALARM state from any other state"
  default     = []
}

variable "alb_target_group_alarms_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to execute when ALB Target Group alarms transition into an OK state from any other state"
  default     = []
}

variable "alb_target_group_alarms_insufficient_data_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to execute when ALB Target Group alarms transition into an INSUFFICIENT_DATA state from any other state"
  default     = []
}

variable "traefik_launch_type" {
  type        = string
  description = "The launch type on which to run your service. Valid values are `EC2` and `FARGATE`"
  default     = "FARGATE"
}

variable "traefik_assign_public_ip" {
  type        = bool
  default     = false
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false."
}

variable "traefik_container_name" {
  type        = string
  default     = "traefik"
  description = "The name of the container in task definition to associate with the load balancer"
}

variable "traefik_container_http_port" {
  type        = number
  default     = 80
  description = "Port at which Traefik will accept traffic from ALB"
}

variable "traefik_task_image" {
  type        = string
  default     = "library/traefik:1.7"
  description = "Traefik image"
}

variable "traefik_task_cpu" {
  type        = number
  description = "The vCPU setting to control cpu limits of traefik container. (If FARGATE launch type is used below, this must be a supported vCPU size from the table here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = 256
}

variable "traefik_task_memory" {
  type        = number
  description = "The amount of RAM to allow traefik container to use in MB. (If FARGATE launch type is used below, this must be a supported Memory size from the table here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = 512
}

variable "traefik_task_memory_reservation" {
  type        = number
  description = "The amount of RAM (Soft Limit) to allow traefik container to use in MB. This value must be less than container_memory if set"
  default     = 128
}

variable "traefik_log_level" {
  type        = string
  default     = "INFO"
  description = "Traefk log level. See https://docs.traefik.io/configuration/logs/"
}

variable "traefik_log_format" {
  type        = string
  default     = "common"
  description = "Traefk log format. See https://docs.traefik.io/configuration/logs/"
}

variable "traefik_logs_retention" {
  type        = number
  default     = 30
  description = "Defines retention period in days for Traefik logs in Cloudwatch"
}

variable "traefik_logs_region" {
  type        = string
  default     = ""
  description = "AWS region for storing Cloudwatch logs from traefik container. Defaults to the same as ECS Cluster region."
}

variable "traefik_dashboard_enabled" {
  type        = bool
  default     = false
  description = "Defines whether traefik dashboard is enabled"
}

variable "traefik_dashboard_host" {
  type        = string
  default     = "dashboard.example.com"
  description = "Traefik dashboard host at which API should be exposed"
}

variable "traefik_dashboard_basic_auth_enabled" {
  type        = bool
  default     = true
  description = "Defines whther basic auth is enabled for Traefik dashboard or not"
}

variable "traefik_dashboard_basic_auth_user" {
  type        = string
  default     = "admin"
  description = "Basic auth username for Traefik dashboard"
}

variable "traefik_dashboard_basic_auth_password" {
  type        = string
  default     = ""
  description = "Basic auth password for Traefik dashboard. If left empty, a random one will be generated."
}

variable "traefik_desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  default     = 1
  type        = number
}

variable "traefik_deployment_controller_type" {
  description = "Type of deployment controller. Valid values: `CODE_DEPLOY`, `ECS`."
  default     = "ECS"
  type        = string
}

variable "traefik_deployment_maximum_percent" {
  description = "The upper limit of the number of tasks (as a percentage of `desired_count`) that can be running in a service during a deployment"
  default     = 200
  type        = number
}

variable "traefik_deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of `desired_count`) of the number of tasks that must remain running and healthy in a service during a deployment"
  default     = 100
  type        = number
}

variable "traefik_mount_points" {
  type = list(object({
    containerPath = string
    sourceVolume  = string
  }))

  description = "Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume`"
  default     = null
}

variable "traefik_volumes" {
  type = list(object({
    host_path = string
    name      = string
    docker_volume_configuration = list(object({
      autoprovision = bool
      driver        = string
      driver_opts   = map(string)
      labels        = map(string)
      scope         = string
    }))
  }))
  description = "Task volume definitions as list of configuration objects"
  default     = []
}

variable "traefik_ignore_changes_task_definition" {
  type        = bool
  description = "Whether to ignore changes in container definition and task definition in the ECS service"
  default     = true
}

variable "traefik_autoscaling_enabled" {
  type        = bool
  description = "A boolean to enable/disable Autoscaling policy for ECS Service"
  default     = false
}

variable "traefik_autoscaling_dimension" {
  type        = string
  description = "Dimension to autoscale on (valid options: cpu, memory)"
  default     = "memory"
}

variable "traefik_autoscaling_min_capacity" {
  type        = number
  description = "Minimum number of running instances of a Service"
  default     = 1
}

variable "traefik_autoscaling_max_capacity" {
  type        = number
  description = "Maximum number of running instances of a Service"
  default     = 2
}

variable "traefik_autoscaling_scale_up_adjustment" {
  type        = number
  description = "Scaling adjustment to make during scale up event"
  default     = 1
}

variable "traefik_autoscaling_scale_up_cooldown" {
  type        = number
  description = "Period (in seconds) to wait between scale up events"
  default     = 60
}

variable "traefik_autoscaling_scale_down_adjustment" {
  type        = number
  description = "Scaling adjustment to make during scale down event"
  default     = -1
}

variable "traefik_autoscaling_scale_down_cooldown" {
  type        = number
  description = "Period (in seconds) to wait between scale down events"
  default     = 300
}

variable "traefik_ecs_alarms_enabled" {
  type        = bool
  description = "A boolean to enable/disable CloudWatch Alarms for ECS Service metrics"
  default     = false
}

variable "traefik_ecs_alarms_cpu_utilization_high_threshold" {
  type        = number
  description = "The maximum percentage of CPU utilization average"
  default     = 80
}

variable "traefik_ecs_alarms_cpu_utilization_high_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "traefik_ecs_alarms_cpu_utilization_high_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "traefik_ecs_alarms_cpu_utilization_high_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High Alarm action"
  default     = []
}

variable "traefik_ecs_alarms_cpu_utilization_high_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High OK action"
  default     = []
}

variable "traefik_ecs_alarms_cpu_utilization_low_threshold" {
  type        = number
  description = "The minimum percentage of CPU utilization average"
  default     = 20
}

variable "traefik_ecs_alarms_cpu_utilization_low_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "traefik_ecs_alarms_cpu_utilization_low_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "traefik_ecs_alarms_cpu_utilization_low_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low Alarm action"
  default     = []
}

variable "traefik_ecs_alarms_cpu_utilization_low_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low OK action"
  default     = []
}

variable "traefik_ecs_alarms_memory_utilization_high_threshold" {
  type        = number
  description = "The maximum percentage of Memory utilization average"
  default     = 80
}

variable "traefik_ecs_alarms_memory_utilization_high_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "traefik_ecs_alarms_memory_utilization_high_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "traefik_ecs_alarms_memory_utilization_high_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High Alarm action"
  default     = []
}

variable "traefik_ecs_alarms_memory_utilization_high_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High OK action"
  default     = []
}

variable "traefik_ecs_alarms_memory_utilization_low_threshold" {
  type        = number
  description = "The minimum percentage of Memory utilization average"
  default     = 20
}

variable "traefik_ecs_alarms_memory_utilization_low_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for the alarm"
  default     = 1
}

variable "traefik_ecs_alarms_memory_utilization_low_period" {
  type        = number
  description = "Duration in seconds to evaluate for the alarm"
  default     = 300
}

variable "traefik_ecs_alarms_memory_utilization_low_alarm_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low Alarm action"
  default     = []
}

variable "traefik_ecs_alarms_memory_utilization_low_ok_actions" {
  type        = list(string)
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low OK action"
  default     = []
}
