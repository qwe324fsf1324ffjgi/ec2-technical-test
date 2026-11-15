# Evidence from 14 November 2026

| Observation | Evidence | Interpretation |
| --- | --- | --- |
| Landing page and health response | [Website](website.png), [health](health.png) | Historical browser views. Live links are in the project README. |
| GuardDuty alert in inbox | [Sample finding](guardduty-email.png) | Synthetic Backdoor:EC2/DenialOfService.Tcp finding, severity 8, region eu-north-1. |
| Instance status alert and recovery in inbox | [ALARM](status-alarm-email.png), [OK](status-recovery-email.png) | The operator deliberately triggered the state transition. The generic email text describes the alarm threshold. Healthy metrics returned it to OK. |
| Restore, monitoring, patching, audit and final plan | [Terminal excerpts](terminal.txt), [verification record](../VERIFICATION.md) | Selected output from the operator's sessions. |

Images are crops of the supplied screenshots. Browser chrome, mailbox navigation and subscription links were removed. Terminal excerpts are preserved as text. Website-content alarm and recovery actions succeeded in CloudWatch. Inbox screenshots cover the separate EC2 status alarm.
