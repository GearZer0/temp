import csv
import base64
import requests

# Set up your RiskIQ API credentials
api_key = 'YOUR_API_KEY'
api_secret = 'YOUR_API_SECRET'

# URL for the API endpoint
api_url = 'https://api.riskiq.net/'

def retrieve_first_last_seen(domain):
    endpoint = f'{api_url}v1/passiveTotal/search/query'

    # Encode API key and secret
    encoded_api_key = base64.b64encode(f'{api_key}:{api_secret}'.encode()).decode()

    headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': f'Basic {encoded_api_key}'
    }

    # Build the payload
    payload = {
        'query': f'(*.{domain})',
        'field': 'firstSeen,lastSeen'
    }

    response = requests.post(endpoint, headers=headers, json=payload)

    if response.status_code == 200:
        data = response.json()
        if data.get('results'):
            result = data['results'][0]
            first_seen = result['firstSeen']
            last_seen = result['lastSeen']
            print(f"Domain: {domain}")
            print(f"First Seen: {first_seen}")
            print(f"Last Seen: {last_seen}")
        else:
            print(f"No data found for domain: {domain}")
    else:
        print(f"Error retrieving data for domain: {domain}")
        print(f"Status Code: {response.status_code}")
        print(f"Error Message: {response.text}")

# Read domains from a CSV file
def read_domains_from_csv(filename):
    with open(filename, 'r') as csv_file:
        reader = csv.reader(csv_file)
        next(reader)  # Skip header row if present
        domains = [row[0] for row in reader]
    return domains

# CSV file containing domains
csv_filename = 'domains.csv'

# Retrieve domains from CSV file
domains = read_domains_from_csv(csv_filename)

# Iterate over the domains and retrieve first and last seen dates
for domain in domains:
    retrieve_first_last_seen(domain)
