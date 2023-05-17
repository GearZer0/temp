import csv
import requests

USERNAME = 'your_username'
KEY = 'your_api_key'
API_URL = 'https://api.riskiq.net/pt/v2/dns/passive'

def get_passive_dns(domain):
    url = f'{API_URL}?query={domain}'
    response = requests.get(url, auth=(USERNAME, KEY))
    if response.status_code == 200:
        data = response.json()
        if 'firstSeen' in data and 'lastSeen' in data:
            first_seen = data['firstSeen']
            last_seen = data['lastSeen']
            return first_seen, last_seen
    return None, None

# Read domains from CSV file
csv_file = 'domains.csv'  # Replace with your CSV file path
with open(csv_file, 'r') as file:
    reader = csv.reader(file)
    next(reader)  # Skip header row if present
    for row in reader:
        domain = row[0]  # Assuming the domain is in the first column of the CSV
        first_seen, last_seen = get_passive_dns(domain)
        print(f"Domain: {domain}")
        print(f"First Seen: {first_seen}")
        print(f"Last Seen: {last_seen}")
        print()
