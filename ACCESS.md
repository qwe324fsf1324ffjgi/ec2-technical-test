> Release update - 15 November 2026: see STATUS.md and ACCEPTANCE.md for the latest evidence. This technical/historical guide retains its original scope. Automatic backup execution is now observed; GuardDuty and EC2-status inbox messages are evidenced. Remaining MFA, website-content inbox and cost claims are scoped in STATUS.md.

# Access and audit boundaries

Latest acceptance updates and account/time scope are recorded in [STATUS.md](STATUS.md).

## Profiles

`ec2-test` uses temporary credentials supplied by the AWS CLI default login and has AdministratorAccess through the existing Identity Center bootstrap role. Keep this for deployment; it remains a powerful, separate access path. MFA enforcement was not verified. The role ARN contains `eu-west-1`; an empty Identity Center inventory in Stockholm does not prove Identity Center is absent.

`ec2-test-operator` assumes the Terraform-managed operator role for one-hour AWS sessions. Its policy permits start/stop and SSM shell access to the Terraform-managed instance, access to the selected logged session document, managing its own sessions, and selected EC2/SSM/CloudWatch read operations. Read/list APIs using `Resource="*"` expose account inventory where those APIs do not support useful resource scoping. It has no supplied IAM editing, EC2 termination, Terraform-state access or Run Command permission.

Successful assume-role, SSM connection and exit were observed. `TerminateInstances --dry-run` returned UnauthorizedOperation. This verifies that denial for the tested action, not every possible API. Existing bootstrap access was not removed or reduced. `ssm-user` retains sudo, so this is trusted server-administrator access, not an unprivileged application-user account.

To create the operator profile after deployment:

```powershell
$operatorArn = terraform output -raw operator_role_arn
aws configure set role_arn $operatorArn --profile ec2-test-operator
aws configure set source_profile ec2-test --profile ec2-test-operator
aws configure set role_session_name zerah-operator --profile ec2-test-operator
aws configure set region eu-north-1 --profile ec2-test-operator
aws sts get-caller-identity --profile ec2-test-operator --no-cli-pager
```

Use a unique, attributable role session name per human. The role trusts the configured bootstrap role, not arbitrary identities. The existing login's administrator privileges are not made safe merely by also creating an operator profile.

## Logging

The regional `SSM-SessionManagerRunShell` document streams interactive commands and output to `/ec2-test/ssm-sessions`, retained 30 days. Its idle timeout is 20 minutes and maximum shell duration 60 minutes. A real session transcript with principal ARN, target and test command was observed. These preferences affect future sessions using the document; they do not retroactively log earlier sessions. CloudWatch encrypts stored log data by default; no customer-managed KMS key was configured, and `cloudWatchEncryptionEnabled=false` does not require a customer-managed key.

The server role has AmazonSSMManagedInstanceCore plus permission to describe log groups and write only its session log group. AmazonSSMManagedInstanceCore is an AWS-managed policy, not a fully project-scoped custom policy. Session logs can contain entered secrets: avoid pasting credentials into the shell. CloudTrail logs SSM API calls; transcripts are separate records. SSH/port-forward content is not covered by this tested shell-logging flow, and the operator policy grants only the selected shell document.

References: https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-restrict-access-examples.html and https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-logging.html
