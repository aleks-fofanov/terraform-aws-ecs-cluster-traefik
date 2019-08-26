<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

# terraform-aws-ecs-traefik-service [![Build Status](https://travis-ci.org/aleks-fofanov/terraform-aws-ecs-cluster-traefik.svg?branch=master)](https://travis-ci.org/aleks-fofanov/terraform-aws-ecs-cluster-traefik) [![Latest Release](https://img.shields.io/github/release/aleks-fofanov/terraform-aws-ecs-cluster-traefik.svg)](https://github.com/aleks-fofanov/terraform-aws-ecs-cluster-traefik/releases/latest)


Terraform module to provision ECS cluster with [Traefik](https://traefik.io/) as an edge router


---


It's 100% Open Source and licensed under the [APACHE2](LICENSE).









## Introduction

This module helps to provision production-ready ECS cluster for your workloads and all required infrastructure for the
cluster (VPC, subnets, ALB, EC2 autoscaling group etc).

Traefik service in ECS cluster is supposed to act as an edge router and route traffic to other containers in your
cluster based on their docker lables.

For more information on which docker labels to set on your container, see
[Traefik documentation](https://docs.traefik.io/configuration/backends/docker/#on-containers).

SSL termination is done on AWS ALB. Traefik tasks are launched with `awsvpc` network mode and needs
Internet access to connect to ECS API in order to discover containers in your ECS cluster.

**Implementation notes and Warnings**:
- If you decide not to use NAT instance or NAT Gateway for private subnets withing the VPC, EC2 ASG instances will be
  launched in public subnets within the VPC as they need internet access to communicated with ECS API. Otherwise, the
  instances will be launched in private subnets.
- If you decide to launch Traefik using `FARGATE` launch type, remember to assing public IP for Traefik so the Traefik
  image can be pulled from Dockerhub.
- There are other networking-related caveates that you may encounter when launching your workloads within ECS cluster,
  please get yourself acquainted with the
  [Task Networking Considerations](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html#task-networking-considerations)
  document to properly setup netwoking for your tasks.

This module is backed by best of breed terraform modules maintained by [Cloudposse](https://github.com/cloudposse).

## Usage


**IMPORTANT:** The `master` branch is used in `source` just as an example. In your code, do not pin to `master` because there may be breaking changes between releases.
Instead pin to the release tag (e.g. `?ref=tags/x.y.z`) of one of our [latest releases](https://github.com/aleks-fofanov/terraform-aws-ecs-cluster-traefik/releases).


This example creates an ECS cluster with Traefik service launched using `FARGATE`.

```hcl
module "ecs_cluster" {
  source    = "git::https://github.com/aleks-fofanov/terraform-aws-ecs-cluster-traefik.git?ref=master"
  name      = "traefik"
  namespace = "cp"
  stage     = "prod"

  vpc_nat_gateway_enabled     = "false"
  vpc_map_public_ip_on_launch = "false"

  alb_certificate_arn                  = "XXXXXXXXXXX"
  alb_http_enabled                     = "true"
  alb_https_enabled                    = "true"
  alb_http_to_https_redirect_enabled   = "true"
  alb_http_to_https_redirect_permanent = "true"
  alb_access_logs_enabled              = "false"

  traefik_launch_type      = "FARGATE"
  traefik_assign_public_ip = "true"
}
```




## Examples

### Example With [Traefik Dashboard](https://docs.traefik.io/configuration/api/) and Autoscaling Enabled

This example launches a Traefik setvice in ECS using `FARGATE` with enabled dashboard, API endpoints and autoscaling.
Basic auth is enabled by default for both API and dashboard. You can use `openssl` to generate password for
basic auth:
```bash
openssl passwd -apr1
```

```hcl
module "ecs_cluster" {
  source    = "git::https://github.com/aleks-fofanov/terraform-aws-ecs-cluster-traefik.git?ref=master"
  name      = "traefik"
  namespace = "cp"
  stage     = "prod"

  vpc_nat_gateway_enabled     = "false"
  vpc_map_public_ip_on_launch = "false"

  alb_certificate_arn                  = "XXXXXXXXXXX"
  alb_http_enabled                     = "true"
  alb_https_enabled                    = "true"
  alb_http_to_https_redirect_enabled   = "true"
  alb_http_to_https_redirect_permanent = "true"
  alb_access_logs_enabled              = "false"

  traefik_launch_type      = "FARGATE"
  traefik_assign_public_ip = "true"

  traefik_dashboard_enabled             = "true"
  traefik_dashboard_host                = "traefik.example.com"
  traefik_dashboard_basic_auth_user     = "admin"
  traefik_dashboard_basic_auth_password = "$$$apr1$$$Rj21EpGU$$$KCwTHCbAIVhw0BiSdU4Me0"

  traefik_autoscaling_enabled             = "true"
  traefik_autoscaling_dimension           = "cpu"
  traefik_autoscaling_min_capacity        = "1"
  traefik_autoscaling_max_capacity        = "3"
  traefik_autoscaling_scale_up_cooldown   = "60"
  traefik_autoscaling_scale_down_cooldown = "60"

  traefik_ecs_alarms_enabled                        = "true"
  traefik_ecs_alarms_cpu_utilization_high_threshold = "20"
  traefik_ecs_alarms_cpu_utilization_low_threshold  = "10"
}
```

### Complete Example

This example:

* Launches Traefik service in ECS using FARGATE with autoscaling
* Enables Traefik API and dashboard
* Enables ALB target group alarms
* Launches EC2 autoscaling group with minimum 2 instances for your workloads
*

```hcl
module "ecs_cluster" {
  source    = "git::https://github.com/aleks-fofanov/terraform-aws-ecs-cluster-traefik.git?ref=master"
  name      = "traefik"
  namespace = "cp"
  stage     = "prod"

  vpc_nat_gateway_enabled     = "false"
  vpc_map_public_ip_on_launch = "false"

  ec2_asg_enabled                  = "true"
  ec2_asg_instance_type            = "t3.large"
  ec2_asg_autoscaling_min_capacity = "2"

  alb_certificate_arn                  = "XXXXXXXXXXX"
  alb_http_enabled                     = "true"
  alb_https_enabled                    = "true"
  alb_http_to_https_redirect_enabled   = "true"
  alb_http_to_https_redirect_permanent = "true"
  alb_access_logs_enabled              = "false"
  alb_target_group_alarms_enabled      = "true"

  traefik_launch_type      = "FARGATE"
  traefik_assign_public_ip = "true"

  traefik_dashboard_enabled             = "true"
  traefik_dashboard_host                = "traefik.example.com"
  traefik_dashboard_basic_auth_user     = "admin"
  traefik_dashboard_basic_auth_password = "$$$apr1$$$Rj21EpGU$$$KCwTHCbAIVhw0BiSdU4Me0"

  traefik_autoscaling_enabled             = "true"
  traefik_autoscaling_dimension           = "cpu"
  traefik_autoscaling_min_capacity        = "1"
  traefik_autoscaling_max_capacity        = "3"
  traefik_autoscaling_scale_up_cooldown   = "60"
  traefik_autoscaling_scale_down_cooldown = "60"

  traefik_ecs_alarms_enabled                        = "true"
  traefik_ecs_alarms_cpu_utilization_high_threshold = "20"
  traefik_ecs_alarms_cpu_utilization_low_threshold  = "10"
}
```



## Makefile Targets
```
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb_access_logs_enabled | A boolean flag to enable/disable access_logs | string | `true` | no |
| alb_access_logs_prefix | The S3 bucket prefix | string | `` | no |
| alb_access_logs_region | The region for the access_logs S3 bucket | string | `us-east-1` | no |
| alb_access_logs_s3_bucket_force_destroy | A boolean that indicates all objects should be deleted from the ALB access logs S3 bucket so that the bucket can be destroyed without error | string | `false` | no |
| alb_certificate_arn | The ARN of the default SSL certificate for HTTPS listener | string | `` | no |
| alb_deletion_protection_enabled | A boolean flag to enable/disable deletion protection for ALB | string | `false` | no |
| alb_http2_enabled | A boolean flag to enable/disable HTTP/2 | string | `true` | no |
| alb_http_enabled | A boolean flag to enable/disable HTTP listener | string | `true` | no |
| alb_http_ingress_cidr_blocks | List of CIDR blocks to allow in HTTP security group | list | `<list>` | no |
| alb_http_ingress_prefix_list_ids | List of prefix list IDs for allowing access to HTTP ingress security group | list | `<list>` | no |
| alb_http_port | The port for the HTTP listener | string | `80` | no |
| alb_http_to_https_redirect_enabled | Defines whether HTTP traffic should be redirected to HTTPS on ALB | string | `true` | no |
| alb_http_to_https_redirect_permanent | Defines whether HTTP to HTTPS redirect on ALB should be permanent (i.e. return 301 or 302 HTTP code). | string | `true` | no |
| alb_https_enabled | A boolean flag to enable/disable HTTPS listener | string | `false` | no |
| alb_https_ingress_cidr_blocks | List of CIDR blocks to allow in HTTPS security group | list | `<list>` | no |
| alb_https_ingress_prefix_list_ids | List of prefix list IDs for allowing access to HTTPS ingress security group | list | `<list>` | no |
| alb_https_port | The port for the HTTPS listener | string | `443` | no |
| alb_https_ssl_policy | The name of the SSL Policy for the listener. | string | `ELBSecurityPolicy-2015-05` | no |
| alb_idle_timeout | The time in seconds that the connection is allowed to be idle | string | `60` | no |
| alb_security_group_ids | A list of additional security group IDs to allow access to ALB | list | `<list>` | no |
| alb_target_group_alarms_3xx_threshold | The maximum number of 3XX HTTPCodes in a given period for ECS Service | string | `25` | no |
| alb_target_group_alarms_4xx_threshold | The maximum number of 4XX HTTPCodes in a given period for ECS Service | string | `25` | no |
| alb_target_group_alarms_5xx_threshold | The maximum number of 5XX HTTPCodes in a given period for ECS Service | string | `25` | no |
| alb_target_group_alarms_alarm_actions | A list of ARNs (i.e. SNS Topic ARN) to execute when ALB Target Group alarms transition into an ALARM state from any other state | list | `<list>` | no |
| alb_target_group_alarms_enabled | A boolean to enable/disable CloudWatch Alarms for ALB Target metrics | string | `false` | no |
| alb_target_group_alarms_evaluation_periods | The number of periods to analyze for ALB CloudWatch Alarms | string | `1` | no |
| alb_target_group_alarms_insufficient_data_actions | A list of ARNs (i.e. SNS Topic ARN) to execute when ALB Target Group alarms transition into an INSUFFICIENT_DATA state from any other state | list | `<list>` | no |
| alb_target_group_alarms_ok_actions | A list of ARNs (i.e. SNS Topic ARN) to execute when ALB Target Group alarms transition into an OK state from any other state | list | `<list>` | no |
| alb_target_group_alarms_period | The period (in seconds) to analyze for ALB CloudWatch Alarms | string | `300` | no |
| alb_target_group_alarms_response_time_threshold | The maximum ALB Target Group response time | string | `0.5` | no |
| attributes | Additional attributes, e.g. `1` | list | `<list>` | no |
| delimiter | Delimiter to be used between `namespace`, `name`, `stage` and `attributes` | string | `-` | no |
| ec2_asg_autoscaling_cpu_utilization_high_evaluation_periods | The number of periods over which data is compared to the specified threshold | string | `2` | no |
| ec2_asg_autoscaling_cpu_utilization_high_period_seconds | The period in seconds over which the specified statistic is applied | string | `300` | no |
| ec2_asg_autoscaling_cpu_utilization_high_statistic | The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum` | string | `Average` | no |
| ec2_asg_autoscaling_cpu_utilization_high_threshold_percent | The value against which the specified statistic is compared | string | `90` | no |
| ec2_asg_autoscaling_cpu_utilization_low_evaluation_periods | The number of periods over which data is compared to the specified threshold | string | `2` | no |
| ec2_asg_autoscaling_cpu_utilization_low_period_seconds | The period in seconds over which the specified statistic is applied | string | `300` | no |
| ec2_asg_autoscaling_cpu_utilization_low_statistic | The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum` | string | `Average` | no |
| ec2_asg_autoscaling_cpu_utilization_low_threshold_percent | The value against which the specified statistic is compared | string | `10` | no |
| ec2_asg_autoscaling_max_capacity | Maximum number of running EC2 instances in ASG | string | `3` | no |
| ec2_asg_autoscaling_min_capacity | Minimum number of running EC2 instances in ASG | string | `2` | no |
| ec2_asg_autoscaling_policies_enabled | Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling | string | `true` | no |
| ec2_asg_autoscaling_scale_down_adjustment_type | Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity` | string | `ChangeInCapacity` | no |
| ec2_asg_autoscaling_scale_down_cooldown_seconds | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start | string | `300` | no |
| ec2_asg_autoscaling_scale_down_policy_type | The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling` | string | `SimpleScaling` | no |
| ec2_asg_autoscaling_scale_down_scaling_adjustment | The number of instances by which to scale. `scale_down_scaling_adjustment` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity | string | `-1` | no |
| ec2_asg_autoscaling_scale_up_adjustment_type | Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity` | string | `ChangeInCapacity` | no |
| ec2_asg_autoscaling_scale_up_cooldown_seconds | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start | string | `300` | no |
| ec2_asg_autoscaling_scale_up_policy_type | The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling` | string | `SimpleScaling` | no |
| ec2_asg_autoscaling_scale_up_scaling_adjustment | The number of instances by which to scale. `scale_up_adjustment_type` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity | string | `1` | no |
| ec2_asg_block_device_mappings | Specify volumes to attach to the instance in ASG besides the volumes specified by the AMI | list | `<list>` | no |
| ec2_asg_credit_specification | Customize the credit specification of the instances in ASG | list | `<list>` | no |
| ec2_asg_default_cooldown | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start | string | `300` | no |
| ec2_asg_disable_api_termination | If `true`, enables EC2 Instance Termination Protection for instances in ASG | string | `false` | no |
| ec2_asg_ebs_optimized | If true, the launched EC2 instances in ASG will be EBS-optimized | string | `false` | no |
| ec2_asg_elastic_gpu_specifications | Specifications of Elastic GPU to attach to the instances in ASG | list | `<list>` | no |
| ec2_asg_enable_monitoring | Enable/disable detailed monitoring of the instanes in ASG | string | `true` | no |
| ec2_asg_enabled | Defines whether autoscaling EC2 instance group should be provisioned for a ECS cluster | string | `false` | no |
| ec2_asg_enabled_metrics | A list of metrics to collect. The allowed values are `GroupMinSize`, `GroupMaxSize`, `GroupDesiredCapacity`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupTerminatingInstances`, `GroupTotalInstances` | list | `<list>` | no |
| ec2_asg_force_delete | Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling | string | `false` | no |
| ec2_asg_health_check_grace_period | Time (in seconds) after instance comes into service before checking health | string | `300` | no |
| ec2_asg_health_check_type | Controls how health checking is done. Valid values are `EC2` or `ELB` | string | `EC2` | no |
| ec2_asg_instance_initiated_shutdown_behavior | Shutdown behavior for the instances in ASG. Can be `stop` or `terminate` | string | `terminate` | no |
| ec2_asg_instance_market_options | The market (purchasing) option for the instances in ASG | list | `<list>` | no |
| ec2_asg_instance_type | Instance type to launch | string | `t3.micro` | no |
| ec2_asg_key_name | The SSH key name that should be used for the instances in ASG | string | `` | no |
| ec2_asg_metrics_granularity | The granularity to associate with the metrics to collect. The only valid value is 1Minute | string | `1Minute` | no |
| ec2_asg_placement | The placement specifications of the instances in ASG | list | `<list>` | no |
| ec2_asg_placement_group | The name of the placement group into which you'll launch your instances, if any | string | `` | no |
| ec2_asg_protect_from_scale_in | Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events | string | `false` | no |
| ec2_asg_security_group_ids | A list of security group IDs to be associated with instances in ASG | list | `<list>` | no |
| ec2_asg_service_linked_role_arn | The ARN of the service-linked role that the ASG will use to call other AWS services | string | `` | no |
| ec2_asg_suspended_processes | A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your autoscaling group from functioning properly. | list | `<list>` | no |
| ec2_asg_termination_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default` | list | `<list>` | no |
| ec2_asg_wait_for_capacity_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior | string | `10m` | no |
| ecs_disable_privilegged_mode | Defines whether privilegged mode should be disabed for containers running with launch type EC2 | string | `true` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | string | `traefik` | no |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | `cp` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | `prod` | no |
| tags | Additional tags (e.g. `map(`BusinessUnit`,`XYZ`) | map | `<map>` | no |
| traefik_assign_public_ip | Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false. | string | `false` | no |
| traefik_autoscaling_dimension | Dimension to autoscale on (valid options: cpu, memory) | string | `memory` | no |
| traefik_autoscaling_enabled | A boolean to enable/disable Autoscaling policy for ECS Service | string | `false` | no |
| traefik_autoscaling_max_capacity | Maximum number of running instances of a Service | string | `2` | no |
| traefik_autoscaling_min_capacity | Minimum number of running instances of a Service | string | `1` | no |
| traefik_autoscaling_scale_down_adjustment | Scaling adjustment to make during scale down event | string | `-1` | no |
| traefik_autoscaling_scale_down_cooldown | Period (in seconds) to wait between scale down events | string | `300` | no |
| traefik_autoscaling_scale_up_adjustment | Scaling adjustment to make during scale up event | string | `1` | no |
| traefik_autoscaling_scale_up_cooldown | Period (in seconds) to wait between scale up events | string | `60` | no |
| traefik_container_http_port | Port at which Traefik will accept traffic from ALB | string | `80` | no |
| traefik_container_name | The name of the container in task definition to associate with the load balancer | string | `traefik` | no |
| traefik_dashboard_basic_auth_enabled | Defines whther basic auth is enabled for Traefik dashboard or not | string | `true` | no |
| traefik_dashboard_basic_auth_password | Basic auth password for Traefik dashboard. If left empty, a random one will be generated. | string | `` | no |
| traefik_dashboard_basic_auth_user | Basic auth username for Traefik dashboard | string | `admin` | no |
| traefik_dashboard_enabled | Defines whether traefik dashboard is enabled | string | `false` | no |
| traefik_dashboard_host | Traefik dashboard host at which API should be exposed | string | `dashboard.example.com` | no |
| traefik_deployment_controller_type | Type of deployment controller. Valid values: `CODE_DEPLOY`, `ECS`. | string | `ECS` | no |
| traefik_deployment_maximum_percent | The upper limit of the number of tasks (as a percentage of `desired_count`) that can be running in a service during a deployment | string | `200` | no |
| traefik_deployment_minimum_healthy_percent | The lower limit (as a percentage of `desired_count`) of the number of tasks that must remain running and healthy in a service during a deployment | string | `100` | no |
| traefik_desired_count | The number of instances of the task definition to place and keep running | string | `1` | no |
| traefik_ecs_alarms_cpu_utilization_high_alarm_actions | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High Alarm action | list | `<list>` | no |
| traefik_ecs_alarms_cpu_utilization_high_evaluation_periods | Number of periods to evaluate for the alarm | string | `1` | no |
| traefik_ecs_alarms_cpu_utilization_high_ok_actions | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High OK action | list | `<list>` | no |
| traefik_ecs_alarms_cpu_utilization_high_period | Duration in seconds to evaluate for the alarm | string | `300` | no |
| traefik_ecs_alarms_cpu_utilization_high_threshold | The maximum percentage of CPU utilization average | string | `80` | no |
| traefik_ecs_alarms_cpu_utilization_low_alarm_actions | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low Alarm action | list | `<list>` | no |
| traefik_ecs_alarms_cpu_utilization_low_evaluation_periods | Number of periods to evaluate for the alarm | string | `1` | no |
| traefik_ecs_alarms_cpu_utilization_low_ok_actions | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low OK action | list | `<list>` | no |
| traefik_ecs_alarms_cpu_utilization_low_period | Duration in seconds to evaluate for the alarm | string | `300` | no |
| traefik_ecs_alarms_cpu_utilization_low_threshold | The minimum percentage of CPU utilization average | string | `20` | no |
| traefik_ecs_alarms_enabled | A boolean to enable/disable CloudWatch Alarms for ECS Service metrics | string | `false` | no |
| traefik_ecs_alarms_memory_utilization_high_alarm_actions | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High Alarm action | list | `<list>` | no |
| traefik_ecs_alarms_memory_utilization_high_evaluation_periods | Number of periods to evaluate for the alarm | string | `1` | no |
| traefik_ecs_alarms_memory_utilization_high_ok_actions | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High OK action | list | `<list>` | no |
| traefik_ecs_alarms_memory_utilization_high_period | Duration in seconds to evaluate for the alarm | string | `300` | no |
| traefik_ecs_alarms_memory_utilization_high_threshold | The maximum percentage of Memory utilization average | string | `80` | no |
| traefik_ecs_alarms_memory_utilization_low_alarm_actions | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low Alarm action | list | `<list>` | no |
| traefik_ecs_alarms_memory_utilization_low_evaluation_periods | Number of periods to evaluate for the alarm | string | `1` | no |
| traefik_ecs_alarms_memory_utilization_low_ok_actions | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low OK action | list | `<list>` | no |
| traefik_ecs_alarms_memory_utilization_low_period | Duration in seconds to evaluate for the alarm | string | `300` | no |
| traefik_ecs_alarms_memory_utilization_low_threshold | The minimum percentage of Memory utilization average | string | `20` | no |
| traefik_ignore_changes_task_definition | Whether to ignore changes in container definition and task definition in the ECS service | string | `true` | no |
| traefik_launch_type | The launch type on which to run your service. Valid values are `EC2` and `FARGATE` | string | `FARGATE` | no |
| traefik_log_format | Traefk log format. See https://docs.traefik.io/configuration/logs/ | string | `common` | no |
| traefik_log_level | Traefk log level. See https://docs.traefik.io/configuration/logs/ | string | `INFO` | no |
| traefik_logs_region | AWS region for storing Cloudwatch logs from traefik container. Defaults to the same as ECS Cluster region. | string | `` | no |
| traefik_logs_retention | Defines retention period in days for Traefik logs in Cloudwatch | string | `30` | no |
| traefik_mount_points | Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume` | list | `<list>` | no |
| traefik_task_cpu | The vCPU setting to control cpu limits of traefik container. (If FARGATE launch type is used below, this must be a supported vCPU size from the table here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) | string | `256` | no |
| traefik_task_image | Traefik image | string | `library/traefik:1.7` | no |
| traefik_task_memory | The amount of RAM to allow traefik container to use in MB. (If FARGATE launch type is used below, this must be a supported Memory size from the table here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) | string | `512` | no |
| traefik_task_memory_reservation | The amount of RAM (Soft Limit) to allow traefik container to use in MB. This value must be less than container_memory if set | string | `128` | no |
| traefik_volumes | Task volume definitions as list of maps | list | `<list>` | no |
| vpc_cidr_block | VPC CIDR block | string | `10.10.0.0/16` | no |
| vpc_map_public_ip_on_launch | Instances launched into a public subnet should be assigned a public IP address | string | `true` | no |
| vpc_nat_gateway_enabled | Flag to enable/disable NAT Gateways to allow servers in the private subnets to access the Internet | string | `true` | no |
| vpc_nat_instance_enabled | Flag to enable/disable NAT Instances to allow servers in the private subnets to access the Internet | string | `false` | no |
| vpc_nat_instance_type | NAT Instance type | string | `t3.micro` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_access_logs_bucket_id | The S3 bucket ID for access logs |
| alb_arn | The ARN of the ALB |
| alb_arn_suffix | The ARN suffix of the ALB |
| alb_default_target_group_arn | The default target group ARN |
| alb_dns_name | DNS name of ALB |
| alb_http_listener_arn | The ARN of the HTTP listener |
| alb_https_listener_arn | The ARN of the HTTPS listener |
| alb_listener_arns | A list of all the listener ARNs |
| alb_name | The name of the ALB |
| alb_security_group_id | The security group ID of the ALB |
| alb_zone_id | The ID of the zone which ALB is provisioned |
| ec2_autoscaling_group_arn | The ARN for this AutoScaling Group |
| ec2_autoscaling_group_id | The autoscaling group id |
| ec2_autoscaling_group_name | The autoscaling group name |
| ec2_instance_profile_arn | ARN of instance profile used with ECS cluster instances launched in EC2 ASG |
| ec2_instance_profile_name | Name of instance profile used with ECS cluster instances launched in EC2 ASG |
| ec2_instance_role_arn | ARN of IAM role assumed by ECS cluster instances launched in EC2 ASG |
| ec2_instance_role_name | Name of IAM role assumed by ECS cluster instances launched in EC2 ASG |
| ec2_instance_security_group_id | Id of secufity group associated with ECS cluster instances launched in EC2 ASG |
| ec2_launch_template_arn | The ARN of the launch template |
| ec2_launch_template_id | The ID of the launch template |
| ecs_cluster_arn | ARN of ECS cluster |
| ecs_cluster_id | Id of ECS cluster |
| ecs_cluster_name | Name of ECS cluster |
| traefik_ecs_exec_role_policy_id | The ECS service role policy ID, in the form of role_name:role_policy_name |
| traefik_ecs_exec_role_policy_name | ECS service role name |
| traefik_scale_down_policy_arn | Autoscaling scale up policy ARN |
| traefik_scale_up_policy_arn | Autoscaling scale up policy ARN |
| traefik_service_name | ECS Service name |
| traefik_service_role_arn | ECS Service role ARN |
| traefik_service_security_group_id | Security Group ID of the ECS task |
| traefik_task_definition_family | ECS task definition family |
| traefik_task_definition_revision | ECS task definition revision |
| traefik_task_exec_role_arn | ECS Task exec role ARN |
| traefik_task_exec_role_name | ECS Task role name |
| traefik_task_role_arn | ECS Task role ARN |
| traefik_task_role_id | ECS Task role id |
| traefik_task_role_name | ECS Task role name |
| vpc_availability_zones | List of Availability Zones where subnets were created |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_default_network_acl_id | The ID of the network ACL created by default on VPC creation |
| vpc_default_route_table_id | The ID of the route table created by default on VPC creation |
| vpc_default_security_group_id | The ID of the security group created by default on VPC creation |
| vpc_id | The ID of the VPC |
| vpc_igw_id | The ID of the Internet Gateway |
| vpc_main_route_table_id | The ID of the main route table associated with this VPC. |
| vpc_nat_gateway_ids | IDs of the NAT Gateways created |
| vpc_nat_instance_ids | IDs of the NAT Instances created |
| vpc_private_route_table_ids | IDs of the created private route tables |
| vpc_private_subnet_cidrs | CIDR blocks of the created private subnets |
| vpc_private_subnet_ids | IDs of the created private subnets |
| vpc_public_route_table_ids | IDs of the created public route tables |
| vpc_public_subnet_cidrs | CIDR blocks of the created public subnets |
| vpc_public_subnet_ids | IDs of the created public subnets |




## Related Projects

Check out these related projects.

- [terraform-aws-ecs-traefik-service](https://github.com/aleks-fofanov/terraform-aws-ecs-traefik-service) - Terraform module to provision Traefik service in ECS



## Help

**Got a question?**

File a GitHub [issue](https://github.com/aleks-fofanov/terraform-aws-ecs-cluster-traefik/issues).


## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/aleks-fofanov/terraform-aws-ecs-cluster-traefik/issues) to report any bugs or file feature requests.

### Developing

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2017-2019 Aleksandr Fofanov



## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.








## Trademarks

All other trademarks referenced herein are the property of their respective owners.


### Contributors

|  [![Aleksandr Fofanov][aleks-fofanov_avatar]][aleks-fofanov_homepage]<br/>[Aleksandr Fofanov][aleks-fofanov_homepage] |
|---|

  [aleks-fofanov_homepage]: https://github.com/aleks-fofanov
  [aleks-fofanov_avatar]: https://github.com/aleks-fofanov.png?size=150


