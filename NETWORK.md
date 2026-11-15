# Network

Terraform creates VPC `10.42.0.0/16`, an internet gateway and a public route table associated with two subnets: primary `10.42.10.0/24` and recovery `10.42.20.0/24`. It selects the first two sorted eligible regional AZ names. AZ letters may map differently across accounts; use the generated outputs rather than assuming the same physical AZ.

The server is in the selected `deployment_site`; currently recovery, eu-north-1b. Subnets disable automatic public IPv4 assignment. A separately managed Elastic IP supplies the server's public address and stays allocated across stops and instance replacement.

The security group allows public IPv4 TCP 80/443 inbound and TCP 80/443 outbound. There is no inbound TCP 22 rule, no SSH key pair and no IPv6 deployment. VPC DNS resolution remains available through the Amazon-provided resolver. Outbound access supports SSM, package repositories, ACME and certificate renewal. This is port restriction, not destination allowlisting.

A narrow instance lifecycle ignore applies to `associate_public_ip_address`: the provider reported that flag differently after EIP association and otherwise proposed replacement. The launch setting remains false, and Terraform separately manages the EIP association. No other instance properties are ignored.

Only one instance is active. Having two subnets is preparation for manual recovery, not automatic cross-AZ availability. See RECOVERY.md.
