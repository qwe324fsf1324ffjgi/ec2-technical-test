# Server and certificate

`compute.tf` provisions a t4g.micro ARM64 instance with an encrypted 8 GiB gp3 root disk, IMDSv2, hop limit one and standard CPU credits. Root deletion on instance termination is enabled. SSH is disabled/masked, and SSM supplies administration.

Normal startup renders cloud-init from `server/` files, upgrades AL2023 to its latest release, installs Nginx and Python 3.11, creates a separate Certbot virtual environment, obtains an IP certificate and installs the HTTPS configuration. The bootstrap systemd service retries failed initialization every five minutes. Its completion marker prevents normal repeats. EIP association happens after instance launch, so initial ACME attempts may need retries.

Recovery startup uses the snapshot's files and certificates and enables required services/timers without rewriting website files from the local source. The bootstrap, user-data and snapshot behavior must be considered before updating the site: `user_data_replace_on_change=true` can replace a normal-mode server, while recovery-mode source edits alone do not update the restored site's files. External monitoring compares against local source hashes, so source/live deployments must be coordinated.

Website files: `/srv/ec2-test/site/index.html` and `style.css`. Nginx uses `/etc/nginx/nginx.conf`; health path `/healthz` returns `ok`. HTTPS serves TLS 1.2/1.3 and fixed security headers. The local access/error logs remain on the disk; central Nginx log collection and disk-space alarms were not implemented.

Certificate files live under `/etc/letsencrypt/live/ec2-test/`. An hourly timer, with up to five minutes' jitter and Persistent=true, runs renewal with a Nginx reload hook while the host is running. IP certificates are short-lived: the external monitor flags remaining lifetime <=24 hours or certificate verification failures. The observed certificate expiry at testing was 20 November 2026 04:42:34 UTC; renewals can change this value.

Linux curl and Chrome accepted the certificate. A Certbot renewal dry run succeeded. Windows curl previously hit a Schannel revocation-connectivity error; no TLS verification bypass was used as evidence. Actual future unattended issuance and reload after expiry were not observed in this drill.

Certbot is pinned to 5.4.0 in `/opt/ec2-test-certbot`; its separate Python packages are outside the SSM OS baseline. Review and deliberately upgrade/retest that environment as software releases change. OS patching does not prove those dependencies are current.
