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

csv_file = 'output.csv'
input_csv_file = 'domains.csv'

with open(input_csv_file, 'r') as input_file, open(csv_file, 'w', newline='') as output_file:
    reader = csv.reader(input_file)
    writer = csv.writer(output_file)
    header = next(reader)
    header.extend(['First Seen', 'Last Seen'])
    writer.writerow(header)

    for row in reader:
        domain = row[0]
        first_seen, last_seen = get_passive_dns(domain)
        row.extend([first_seen, last_seen])
        writer.writerow(row)
