import boto3
import json
import argparse
from datetime import datetime, timedelta

def fetch_billing_data(tag_key, tag_value, access_key, secret_key):
    # calculate the dynamic time period (today - 30 days)
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=30)

    # format the dates as required by AWS (YYYY-MM-DD)
    start_date_str = start_date.strftime("%Y-%m-%d")
    end_date_str = end_date.strftime("%Y-%m-%d")

    client = boto3.client(
        'ce',  
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key
    )
    response = client.get_cost_and_usage(
        TimePeriod={
            'Start': start_date_str,
            'End': end_date_str
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
    parser.add_argument('--access_key', required=True, help='AWS Access Key ID')
    parser.add_argument('--secret_key', required=True, help='AWS Secret Key')
    parser.add_argument('--output_file', required=True, help='Output file to save the billing data')
    args = parser.parse_args()

    billing_data = fetch_billing_data(args.tag_key, args.tag_value, args.access_key, args.secret_key)
    
    # write the billing data to the specified output file
    with open(args.output_file, 'w') as f:
        json.dump(billing_data, f, indent=4)
