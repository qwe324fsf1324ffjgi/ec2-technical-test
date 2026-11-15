# Design and tradeoffs

The design runs one t4g.micro Amazon Linux 2023 ARM64 server with an 8 GiB encrypted gp3 root disk. It uses standard CPU credits, basic EC2 monitoring and one retained public IPv4 address. Two routed subnets occupy separate AZs; only one hosts the server. There is no NAT gateway, load balancer, second running server or automatic failover controller.

Terraform owns the AWS configuration; encrypted, versioned S3 state uses native lockfiles. The provider checks the expected account ID. The main operational dependencies are internet connectivity to AWS/package/ACME endpoints, temporary human credentials and the retained Elastic IP.

Public inbound access is limited to HTTP/HTTPS. SSM provides administration without an SSH key pair or inbound SSH; IMDSv2 is required. HTTP supports ACME validation and redirects other requests to HTTPS. Nginx serves fixed files, denies dotfiles and applies content/security headers. No application login, database or dynamic upload surface is present.

Snapshots provide recovery points independent of the source AZ. Recovery is deliberate Terraform replacement in a selected subnet with the EIP reassociated. It is not active-active availability or a measured automatic recovery SLA. Current recovery mode boots a disk image without rewriting its site content from the local working tree.

Scheduler controls daily start/stop. A local timer stops a running server outside the window. The external Lambda runs every five minutes and verifies TLS, certificate lifetime, health and both file hashes during operating hours. At night it emits healthy heartbeat values without contacting the intentionally stopped website. Missing Lambda metric data is breaching; missing foundation metrics are not breaching. The operating-hours policy is encoded in several places; change and verify Scheduler, local enforcement and the Lambda window together.

CloudTrail records management API activity across regions into a private versioned bucket. SSM shell transcripts stream to CloudWatch. GuardDuty foundational detection is enabled only in Stockholm; this is not endpoint runtime or malware scanning. EventBridge routes medium-or-higher findings to SNS. Alerts have no automated remediation action.

Cost is reduced by twelve running hours/day, small compute/storage, no NAT/load balancer and disabled optional GuardDuty plans. The public IP, disk, snapshots, logs, custom metrics and alarms can still accrue charges while EC2 is stopped. See COSTS.md.
