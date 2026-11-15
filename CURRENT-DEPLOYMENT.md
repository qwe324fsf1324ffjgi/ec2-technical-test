> Release update - 15 November 2026: see STATUS.md and ACCEPTANCE.md for the latest evidence. This technical/historical guide retains its original scope. Automatic backup execution is now observed; GuardDuty and EC2-status inbox messages are evidenced. Remaining MFA, website-content inbox and cost claims are scoped in STATUS.md.

# Observed deployment — 14 November 2026

Latest acceptance updates and account/time scope are recorded in [STATUS.md](STATUS.md).

This inventory records the supplied AWS output. Resolve current values with `terraform output` when operating; identifiers may change after replacement. Local account-specific tfvars are intentionally excluded.

| Item | Observed value |
| --- | --- |
| Account / region | `312660809284` / `eu-north-1` |
| Website | `https://16.192.190.65` |
| Current instance / AZ | `i-0d341cc5ce8fd20a7` / `eu-north-1b` |
| Current root volume | `vol-0331a7c76186f6e18` |
| Original instance, now terminated | `i-089b289452aa69694` / `eu-north-1a` |
| Recovery snapshot / AMI | `snap-0248cc99d2eaa7aed` / `ami-0d5ea418134c2b9ce` |
| Normal pinned regional AMI | `ami-067860620db69db65` |
| Primary / recovery subnets | `subnet-05902f65bafe9fd98` / `subnet-013777548f762aa30` |
| VPC / security group | `vpc-048ac0bb3aa5d73a5` / `sg-0de6db7cee00e05f2` |
| EIP allocation | `eipalloc-0cd2a866fa419df7d` |
| State bucket | `ec2-test-tfstate-312660809284-eu-north-1` |
| Audit bucket | `ec2-test-audit-312660809284-eu-north-1` |
| DLM policy | `policy-0b52adace8f128c61` |
| Patch baseline | `pb-078e511dd3f341434` |
| Patch association | `3927abcd-c087-47e9-9dd5-ac717fc0c383` |
| GuardDuty detector | `3959ebba59e6486d9bbb72fa6bcb227c` |
| Monitor Lambda | `ec2-test-website-monitor` |
| Operations topic | `arn:aws:sns:eu-north-1:312660809284:ec2-test-operations` |
| Operator role | `arn:aws:iam::312660809284:role/ec2-test-operator-ae994221b6530214561233eafb` |

Preserve existing settings: `deployment_site="recovery"`, `use_recovery_image=true`, `recovery_snapshot_id="snap-0248cc99d2eaa7aed"`, `enable_corruption_drill=false`. The operator trust points to the existing Identity Center bootstrap role under `aws-reserved/sso.amazonaws.com/eu-west-1/`.

Baseline SHA256:

```text
index.html a04b5cb854eedb6a26216b30c2a01004ff8b7ece3410d4d6fd470bba2a52f6a9
style.css  413164dd07e9d0d3edd90eb0e4bbea365815302da4d33004c14e22173e099f8a
```
