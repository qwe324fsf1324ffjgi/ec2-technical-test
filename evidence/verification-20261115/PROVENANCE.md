# Verification capture - 15 November 2026

The JSON files in this folder were extracted from the uploaded PowerShell transcript, not fetched again from AWS during preparation of this package. The unmodified transcript is retained in the separate private handover.

`Verify-Deployment.ps1` filters `dlm-root-snapshots` by the current instance root volume and the `aws:dlm:lifecycle-policy-id` system tag, using the deployed Terraform policy output. It reports zero failed AWS requests. The filtered snapshot result is the basis for marking automatic backup execution observed. It does not establish future retention deletion or the recoverability of this particular new snapshot without a restore test.

A zero request-failure count means the API calls succeeded. The individual returned values, not that count alone, establish each result. Extracted JSON has been formatted for readability; the source transcript preserves what the operator supplied.
