import boto3
import os
ecs_client = boto3.client('ecs')
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    cluster_name = os.environ['CLUSTER_NAME']
    service_name = os.environ['SERVICE_NAME']
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']

try:
        # Scale down ECS service
        response = ecs_client.update_service(
            cluster=cluster_name,
            service=service_name,
            desiredCount=0
        )
        message = f"✅ Successfully scaled down service '{service_name}' to 0 tasks."
        print(message)

# Publish SNS notification
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject='ECS Service Scale Down Notification'
        )

return {
            'statusCode': 200,
            'body': message
        }

except Exception as e:
        error_message = f"❌ Error scaling down service: {e}"
        print(error_message)

sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=error_message,
            Subject='ECS Service Scale Down Failed'
        )

return {
            'statusCode': 500,
            'body': str(e)
        }

