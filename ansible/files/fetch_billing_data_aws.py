import boto3
import json
import argparse

def fetch_billing_data(tag_key, tag_value):
    client = boto3.client('ce', region_name='us-east-1')
    response = client.get_cost_and_usage(
        TimePeriod={
            'Start': '2023-10-01',
            'End': '2023-10-31'
        },
        Granularity='MONTHLY',
        Filter={
            "Tags": {
                "Key": tag_key,
                "Values": [tag_value]
            }
        },
        Metrics=["UnblendedCost"]
    )
    return response

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--tag_key', required=True, help='Tag key to filter')
    parser.add_argument('--tag_value', required=True, help='Tag value to filter')
    args = parser.parse_args()

    billing_data = fetch_billing_data(args.tag_key, args.tag_value)
    print(json.dumps(billing_data, indent=4))
