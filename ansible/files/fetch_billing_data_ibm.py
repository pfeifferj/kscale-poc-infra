import requests
import json
import argparse
from datetime import datetime, timedelta

def fetch_billing_data_ibm(api_key, account_id, tag_value):
    # get access token
    auth_url = "https://iam.cloud.ibm.com/identity/token"
    auth_headers = {
        "Content-Type": "application/x-www-form-urlencoded"
    }
    auth_data = {
        "grant_type": "urn:ibm:params:oauth:grant-type:apikey",
        "apikey": api_key
    }
    auth_response = requests.post(auth_url, headers=auth_headers, data=auth_data)
    access_token = auth_response.json()["access_token"]

    # calculate date range
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=30)
    
    start_date_str = start_date.strftime("%Y-%m-%dT%H:%M:%SZ")
    end_date_str = end_date.strftime("%Y-%m-%dT%H:%M:%SZ")

    # build usage url for the given month
    billing_url = f"https://billing.cloud.ibm.com/v4/accounts/{account_id}/resource_instances/usage/{start_date.strftime('%Y-%m')}"

    # headers
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    # params without tag filtering
    params = {
        "names": True,   # get resource names
        "limit": 100,    # pagination, adjust as needed
    }

    # fetch the data
    response = requests.get(billing_url, headers=headers, params=params)
    
    if response.status_code != 200:
        raise Exception(f"Error fetching billing data: {response.status_code}, {response.text}")

    data = response.json()

    # filter resources based on tags
    filtered_resources = [
        resource for resource in data['resources']
        if 'tags' in resource and tag_value in resource['tags']
    ]

    return filtered_resources

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--api_key', required=True, help='IBM Cloud API key')
    parser.add_argument('--account_id', required=True, help='IBM Cloud Account ID')
    parser.add_argument('--tag_value', required=True, help='Tag value to filter')
    parser.add_argument('--output_file', required=True, help='Output file to save the billing data')
    args = parser.parse_args()

    billing_data = fetch_billing_data_ibm(args.api_key, args.account_id, args.tag_value)
    
    with open(args.output_file, 'w') as f:
        json.dump(billing_data, f, indent=4)
