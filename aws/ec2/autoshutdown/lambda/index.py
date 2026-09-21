"""Stop running EC2 instances tagged for after-hours shutdown.

Opt in with AutoShutdown=true. Leave unset on long-running services.
"""
import os

import boto3

TAG_KEY = os.environ["AUTO_SHUTDOWN_TAG_KEY"]
TAG_VAL = os.environ["AUTO_SHUTDOWN_TAG_VALUE"]


def handler(event, context):
    ec2 = boto3.client("ec2")
    filters = [
        {"Name": "instance-state-name", "Values": ["running"]},
        {"Name": f"tag:{TAG_KEY}", "Values": [TAG_VAL]},
    ]
    ids = []
    for page in ec2.get_paginator("describe_instances").paginate(Filters=filters):
        for res in page.get("Reservations", []):
            for inst in res.get("Instances", []):
                ids.append(inst["InstanceId"])

    if not ids:
        print("no matching running instances")
        return {"stopped": []}

    stopped = []
    for i in range(0, len(ids), 50):
        chunk = ids[i : i + 50]
        ec2.stop_instances(InstanceIds=chunk)
        stopped.extend(chunk)
        print("stopped", chunk)
    return {"stopped": stopped}
