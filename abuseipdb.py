import csv
import requests

API_KEY = '3dee6de9fb2a565ba8e8fa3972480b9e254e319f87b1f73da3a22e3ff5c2c245ca2037cd1882e8b2'  # Replace with your AbuseIPDB API key

def get_abuseipdb_info(ip):
    url = f'https://api.abuseipdb.com/api/v2/check?ipAddress={ip}&verbose'
    headers = {'Key': API_KEY, 'Accept': 'application/json'}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.json()['data']
        verdict = data['abuseConfidenceScore']
        resolved_domain = data['domain']
        hostname = data['hostnames'][0] if data['hostnames'] else None
        country = data['countryCode']
        return verdict, resolved_domain, hostname, country
    else:
        return None, None, None, None

if __name__ == '__main__':
    input_file = 'input.csv'
    output_file = 'output.csv'
    with open(input_file, 'r') as csv_file, open(output_file, 'w', newline='') as output_csv:
        reader = csv.reader(csv_file)
        writer = csv.writer(output_csv)
        writer.writerow(['IP Address', 'Verdict', 'Resolved Domain', 'Hostname', 'Country'])
        for row in reader:
            ip = row[0]
            verdict, resolved_domain, hostname, country = get_abuseipdb_info(ip)
            writer.writerow([ip, verdict, resolved_domain, hostname, country])
            print(f'IP: {ip}, Verdict: {verdict}, Resolved Domain: {resolved_domain}, Hostname: {hostname}, Country: {country}')
