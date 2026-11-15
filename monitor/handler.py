import hashlib
import json
import os
import socket
import ssl
from datetime import datetime, timedelta, timezone
from urllib.request import urlopen

import boto3

LAGOS = timezone(timedelta(hours=1))
LIMIT = 1024 * 1024


def operating_window(now):
    local = now.astimezone(LAGOS)
    minutes = local.hour * 60 + local.minute
    return 7 * 60 + 5 <= minutes < 19 * 60


def certificate_seconds(host, now):
    context = ssl.create_default_context()
    with socket.create_connection((host, 443), timeout=6) as raw:
        with context.wrap_socket(raw, server_hostname=host) as connection:
            certificate = connection.getpeercert()
    return ssl.cert_time_to_seconds(certificate["notAfter"]) - now.timestamp()


def fetch(host, path):
    url = "https://" + host + path
    with urlopen(url, timeout=6, context=ssl.create_default_context()) as response:
        if response.status != 200 or response.geturl() != url:
            raise ValueError("Unexpected HTTP status or redirect")
        body = response.read(LIMIT + 1)
    if len(body) > LIMIT:
        raise ValueError("Response exceeded size limit")
    return body


def lambda_handler(event, context):
    now = datetime.now(timezone.utc)
    active = operating_window(now)
    website_failure = 0
    certificate_risk = 0
    note = "Outside operating window"

    if active:
        host = os.environ["WEBSITE_IP"]
        try:
            certificate_risk = int(certificate_seconds(host, now) <= 86400)
            if fetch(host, "/healthz").strip() != b"ok":
                raise ValueError("Health endpoint returned unexpected content")
            for path, key in [("/", "INDEX_SHA256"), ("/style.css", "STYLE_SHA256")]:
                actual = hashlib.sha256(fetch(host, path)).hexdigest()
                if actual != os.environ[key].lower():
                    raise ValueError("Website content hash mismatch: " + path)
            note = "HTTPS and content checks passed"
        except ssl.SSLCertVerificationError as error:
            website_failure = 1
            certificate_risk = 1
            note = type(error).__name__ + ": " + str(error)
        except Exception as error:
            website_failure = 1
            note = type(error).__name__ + ": " + str(error)

    result = {
        "active": active,
        "WebsiteFailure": website_failure,
        "CertificateRisk": certificate_risk,
        "note": note,
    }
    print(json.dumps(result))

    metrics = [
        {
            "MetricName": name,
            "Dimensions": [{"Name": "Monitor", "Value": "website"}],
            "Timestamp": now,
            "Unit": "Count",
            "Value": result[name],
        }
        for name in ["WebsiteFailure", "CertificateRisk"]
    ]
    boto3.client("cloudwatch").put_metric_data(
        Namespace="EC2TechnicalTest", MetricData=metrics
    )
    return result