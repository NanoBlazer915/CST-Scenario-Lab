import boto3
from datetime import datetime, timedelta

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    # Get all running instances with the "AutoShutdown=true" tag
    response = ec2.describe_instances(
        Filters=[
            {'Name': 'tag:AutoShutdown', 'Values': ['true']},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            launch_time = instance['LaunchTime']

            # Check if the instance has been running for 8+ hours
            if datetime.now(launch_time.tzinfo) - launch_time > timedelta(hours=8):
                print(f"Stopping instance {instance_id}")
                ec2.stop_instances(InstanceIds=[instance_id])
