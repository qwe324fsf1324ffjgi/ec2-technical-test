# Operations

Use Africa/Lagos (UTC+1) for operator schedules. Evidence timestamps may be UTC or AWS CLI local offsets; compare the offset before calculating durations. Deployment credentials must come from the intended account.

## Daily schedule

| Action | Lagos | UTC |
| --- | --- | --- |
| EC2 start | 07:00 | 06:00 |
| External website checks begin | 07:05 | 06:05 |
| OS Install association | 09:00 | 08:00 |
| EC2 stop; active website checks end | 19:00 | 18:00 |
| DLM snapshot schedule | 21:00 | 20:00 |

DLM initiates within a one-hour scheduling window; snapshot completion can take longer. It can snapshot the stopped EBS-backed server's disk. Do not infer a missed backup merely because it is absent exactly at 21:00. Local shutdown enforcement runs about every five minutes; it is not an exact second-by-second fail-safe.

## Routine checks

Run `Verify-Deployment.ps1` from the project directory using the deployment profile. It reads alarms, patch state, threat-detection state and DLM snapshots and saves evidence. It makes no infrastructure changes. Review errors and outputs; empty snapshot results do not count as backup success.

```powershell
$env:AWS_PROFILE = 'ec2-test'
terraform output
aws cloudwatch describe-alarms --profile ec2-test --region eu-north-1 --alarm-name-prefix ec2-test- --query 'MetricAlarms[].{Name:AlarmName,State:StateValue}' --output table --no-cli-pager
aws logs tail /aws/lambda/ec2-test-website-monitor --profile ec2-test --region eu-north-1 --since 20m --format short --no-cli-pager
aws logs tail /ec2-test/ssm-sessions --profile ec2-test --region eu-north-1 --since 20m --format short --no-cli-pager
```

Use the operator profile for the logged shell described in ACCESS.md. Read-only server checks:

```bash
sudo systemctl is-active nginx amazon-ssm-agent
sudo systemctl list-timers 'ec2-test-*'
sudo sha256sum /srv/ec2-test/site/index.html /srv/ec2-test/site/style.css
curl --fail --show-error --silent --include --max-time 30 https://16.192.190.65/healthz
sudo /opt/ec2-test-certbot/bin/certbot certificates
sudo journalctl -u ec2-test-renew.service -n 30 --no-pager
df -h /
```

## Alarm response

| Alarm | First response |
| --- | --- |
| instance-status | Inspect EC2 system/instance checks and current state; do not terminate reflexively |
| sustained-cpu | Inspect load/processes and standard-credit constraints; consider workload or size changes |
| scheduler-failures | Inspect the SQS failure message and Scheduler role/instance target; resolve before retry |
| security-routing-failures | Inspect EventBridge rule target and SNS policy; verify synthetic test separately |
| notification-failures | Inspect SNS subscription/endpoint delivery; this uses the same SNS topic, not an independent fallback |
| website-failure | Check Lambda log reason, operating window, server, Nginx, TLS and source/live hashes |
| certificate-risk | Inspect notAfter, renewal timer and ACME connectivity; never bypass validation to clear the test |

A healthy EC2 status check does not prove Nginx or content is healthy. Missing external metrics are breaching even overnight; a failed checker can cause both website/certificate alarms. A general connection failure sets WebsiteFailure but does not necessarily set CertificateRisk. The latter is not a complete certificate diagnosis. Alarm delivery depends on AWS services and the configured inbox; the same-channel SNS-failure alarm cannot guarantee delivery during an SNS outage.

Do not repeatedly call set-alarm-state to test detection. The content-change drill already produced a real monitor failure, ALARM SNS action, successful file restoration and recovery SNS action. GuardDuty and instance-status inbox deliveries are confirmed. Website-content email receipt remains open.

## Patching and maintenance

Custom AL2023 baseline approves all classifications and nonsecurity updates without delay. The daily association installs with RebootIfNeeded and can interrupt the single server. Inspect `describe-instance-patch-states`: correct BaselineId/PatchGroup/Operation and zero missing, failed and pending reboot counts. A Scan alone does not prove Install. Initial execution saw an empty patch group and used the AWS default; later Scan and Install used the intended baseline. Allow tag/permission propagation before diagnosing another new machine.

Before risky maintenance, verify a recent completed snapshot. After patching/reboots, verify SSM Online, health, TLS and hashes. After restoring an older snapshot, patch promptly and inspect certificate age. Recheck Certbot's virtual environment separately.

## Local connectivity errors

Repeated DNS/API endpoint failures were observed on the Windows connection. A failed request is not proof of infrastructure failure. Confirm DNS and TCP 443, then `aws sts get-caller-identity --profile ec2-test`; retry the failed read after connectivity recovers. If credentials are explicitly expired, run `aws login --profile default` and choose the intended test account/role. Never share exported credentials or disable TLS verification. Do not redeploy the server to fix laptop DNS.

## Drill cleanup

The snapshot restore-test disk was unmounted and deleted. The monitor drill left `/srv/ec2-test/.monitor-drill-index.html` as a retained backup and scheduled a transient ten-minute restore timer. Before removing that copy, verify the live baseline hash, stop the timer and ensure its service is not running. Do not delete the copy while restoration may still use it. The marker was manually restored at 15:36 Lagos and the external check then passed.

References: https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-ami-policy.html and https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager.html
