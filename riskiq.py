import requests

# Set up your RiskIQ API credentials
api_key = 'YOUR_API_KEY'
api_secret = 'YOUR_API_SECRET'

# URL for the API endpoint
api_url = 'https://api.riskiq.net/'

def retrieve_first_last_seen(domain):
    endpoint = f'{api_url}v1/passiveTotal/search/query'

    headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Api-Key': api_key,
        'Api-Secret': api_secret
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

# List of domains to scan
domains = ['example.com', 'google.com', 'github.com']

# Iterate over the list and retrieve first and last seen dates
for domain in domains:
    retrieve_first_last_seen(domain)
