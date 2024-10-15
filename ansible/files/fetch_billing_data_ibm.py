import requests
import json
import argparse
from datetime import datetime, timedelta

def fetch_billing_data_ibm(api_key, tag_key, tag_value):
    # get access token using the api key
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

    # calculate the dynamic time period (today - 30 days)
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=30)
    
    # format the dates as required by IBM Cloud (ISO 8601 format)
    start_date_str = start_date.strftime("%Y-%m-%dT%H:%M:%SZ")
    end_date_str = end_date.strftime("%Y-%m-%dT%H:%M:%SZ")

    # define the usage url
    billing_url = "https://billing.cloud.ibm.com/v4/accounts/{account_id}/usage"

    # headers for the api request
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    # params to filter by tag and time period
    params = {
        "resource_id": tag_key,
        "resource_instance_name": tag_value,
        "start": start_date_str,
        "end": end_date_str
    }

    # make the request
    response = requests.get(billing_url, headers=headers, params=params)
    return response.json()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--api_key', required=True, help='IBM Cloud API key')
    parser.add_argument('--tag_key', required=True, help='Tag key to filter')
    parser.add_argument('--tag_value', required=True, help='Tag value to filter')
    args = parser.parse_args()

    billing_data = fetch_billing_data_ibm(args.api_key, args.tag_key, args.tag_value)
    print(json.dumps(billing_data, indent=4))
