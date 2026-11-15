# Reviewer walkthrough - 15 November 2026

Open START-HERE.html and REPORT.pdf. Use ACCEPTANCE.md to move from each outcome to its source.

1. During 07:00-19:00 Lagos, open https://16.192.190.65/ and /healthz. Outside that window, use dated captures; scheduled unavailability is intentional.
2. Inspect the current instance status and morning-start evidence. Compare event IDs, target and Scheduler role in the original start/stop responses.
3. Inspect the completed DLM snapshot extract and its provenance, then the current patch state and seven alarm states.
4. Follow the controlled cross-AZ cutover and corrupt-file restore in RECOVERY.md and SESSION-LOG.md. No real AZ outage or exact downtime was measured.
5. Open the earlier gallery for security-group, recovery image, GuardDuty, audit, identity enrollment and notification captures. Specific inbox evidence covers GuardDuty and EC2-status, not website-content ALARM/OK.
6. Inspect ACCESS.md, the operator role and SSM session records. Keep MFA enrollment separate from MFA enforcement and central-account root settings separate from workload-root settings.
7. Review DEPLOYMENT.md, COSTS.md and CLEANUP.md. The second-account deployment and final full recurring-cost figure remain unverified.

Do not run a destructive demonstration or apply saved plans merely to review this work. Source and examples can be inspected offline. Historical captures are evidence of their recorded time, not current AWS state.
