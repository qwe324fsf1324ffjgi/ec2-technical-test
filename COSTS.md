> Release update - 15 November 2026: see STATUS.md and ACCEPTANCE.md for the latest evidence. This technical/historical guide retains its original scope. Automatic backup execution is now observed; GuardDuty and EC2-status inbox messages are evidenced. Remaining MFA, website-content inbox and cost claims are scoped in STATUS.md.

# Cost assumptions and controls

Latest acceptance updates and account/time scope are recorded in [STATUS.md](STATUS.md).

The USD 10 monthly budget is an alert threshold, not a spending cap. The complete stack is not proven to fit it. No credits/free trials are assumed. Rates depend on region, date and usage; use AWS Pricing Calculator and actual account billing for the final quote.

## Historical measured base

The owner ran Get-BaseCost.ps1 against AWS Price List on 13 November 2026 for Stockholm. Its reported 31-day assumptions were:

| Item | Assumption | USD |
| --- | --- | ---: |
| t4g.micro Linux compute | 12h/day × 31 × $0.0086/h | 3.20 |
| Retained IPv4 address | 24h/day × 31 × $0.005/h | 3.72 |
| Root gp3 disk | 8 GiB retained overnight | 0.67 |
| Historical base subtotal | Before tax, data transfer and extras | 7.59 |

This subtotal is not a current all-service quote. The script refreshes EC2/gp3 rates for Stockholm but hardcodes the IPv4 rate and does not price the rest of the stack.

## Additional deployed billable components

| Component | Quantity or billing driver |
| --- | --- |
| CloudWatch custom metrics | 2 distinct standard-resolution metric series; five-minute publication does not make them free |
| CloudWatch alarms | 7 standard metric alarms: 5 foundation + 2 checker |
| Lambda | 8,928 scheduled executions in a 31-day month, plus manual tests/retries; 128 MiB, observed healthy duration roughly 1.3–1.5 seconds |
| Logs | Lambda logs retained 14 days; shell transcripts 30 days; ingestion/storage depend on volume |
| GuardDuty foundational monitoring | Management events and flow/DNS analysis volumes; Stockholm only; optional plans disabled |
| EBS snapshots | Actual stored/incremental blocks and changes; daily 7-day policy plus manual recovery snapshot retained separately |
| S3 | State/audit objects, versions and requests; audit current objects expire after 90 days and noncurrent versions after 7 more days as applicable |
| CloudTrail | One management-event trail copy has no trail event-delivery fee; S3 storage/requests still cost money; no paid data events/Insights/Lake configured |
| Notifications and schedules | SNS email publications/delivery, Scheduler and EventBridge usage, retries and tests |
| Other | Data transfer, taxes, temporary recovery disks and any future additional copies/workloads |

For illustration only, AWS public CloudWatch examples use $0.30/custom metric-month and $0.10/standard alarm-metric-month: 2 × 0.30 + 7 × 0.10 = $1.30, which would bring the historical base to $8.89 **before all other usage**. This is a sensitivity calculation, not a verified Stockholm CloudWatch quote, free-tier assessment or complete budget estimate. Do not present $8.89 as the full expected bill.

Total = compute + retained address + root disk + snapshot storage + S3/versions/requests + metrics + alarms + logs + Lambda + GuardDuty + notifications/events + transfer/tax. Some components continue billing with EC2 stopped. Check Cost Explorer/Billing after usage settles and GuardDuty's usage estimate; no daily estimate was retrieved in this session.

Controls already present: scheduled shutdown, small instance/disk, standard CPU credits, bounded log retention, seven-day DLM age retention and disabled optional GuardDuty plans. Manual recovery snapshots and allocated EIPs require deliberate cleanup. Audit retention is lifecycle-based, not immutable/WORM preservation; versioning is not a guarantee against privileged deletion.

Pricing references reviewed 14 November 2026:
- https://aws.amazon.com/cloudwatch/pricing/
- https://aws.amazon.com/guardduty/pricing/
- https://aws.amazon.com/cloudtrail/pricing/
- https://aws.amazon.com/vpc/pricing/
- https://aws.amazon.com/ebs/pricing/
- https://aws.amazon.com/s3/pricing/
- https://calculator.aws/
