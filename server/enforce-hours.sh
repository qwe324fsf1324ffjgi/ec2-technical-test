#!/bin/bash
set -euo pipefail
hour=$(TZ=Africa/Lagos date +%H)
case "$hour" in
    0[0-6]|19|2[0-3])
        logger -t ec2-test 'Stopping instance outside the 07:00-19:00 operating window.'
        systemctl poweroff
        ;;
esac
