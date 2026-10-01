import os
import json
import re
import requests
from bs4 import BeautifulSoup
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore

# Firebase Setup
service_account_info = json.loads(os.environ['FIREBASE_SERVICE_ACCOUNT'])
cred = credentials.Certificate(service_account_info)
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

db = firestore.client()

# KingOfSatta Market Mapping
MARKET_MAP = {
    "DELHI BAZAR": ["DELHI BAZAR", "DELHI-BAZAR", "DELHI BAZZAR"],
    "SHREE GANESH": ["SHREE GANESH", "SHRI GANESH", "SHREE-GANESH"],
    "FARIDABAD": ["FARIDABAD", "FARIDABAD-DAY"],
    "GHAZIABAD": ["GHAZIABAD", "GAZIABAD"],
    "GALI": ["GALI", "GALI-DESAWAR"],
    "DISAWAR": ["DISAWAR", "DESAWAR", "DISAWAR-KING"],
}

def clean_number(num_str):
    num_str = num_str.strip()
    if num_str in ["XX", "--", "", None]:
        return None
    match = re.search(r'\d+', num_str)
    if match:
        val = match.group(0)
        return val.zfill(2)
    return None

def fetch_and_sync():
    url = "https://kingsofsatta.com/"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    }

    try:
        response = requests.get(url, headers=headers, timeout=15)
        if response.status_code != 200:
            print(f"Failed to fetch site, status: {response.status_code}")
            return

        soup = BeautifulSoup(response.text, 'html.parser')
        page_text = soup.get_text()

        now = datetime.now()
        date_str = now.strftime("%d")
        month_year_str = now.strftime("%m-%Y")

        print(f"Checking results for Date: {date_str}, Month: {month_year_str}")

        # HTML parsing
        tables = soup.find_all('table')
        extracted_results = {}

        for table in tables:
            rows = table.find_all('tr')
            for row in rows:
                cols = [c.get_text(strip=True) for c in row.find_all(['td', 'th'])]
                if len(cols) >= 2:
                    m_name_candidate = cols[0].upper()
                    m_num_candidate = cols[1]

                    for app_market, aliases in MARKET_MAP.items():
                        for alias in aliases:
                            if alias in m_name_candidate:
                                valid_num = clean_number(m_num_candidate)
                                if valid_num and app_market not in extracted_results:
                                    extracted_results[app_market] = valid_num

        print("Extracted Results from Website:", extracted_results)

        # Update Firestore
        for market, number in extracted_results.items():
            # 1. Update Live Result
            res_ref = db.collection('results').document(market)
            res_snap = res_ref.get()

            prev_num = res_snap.to_dict().get('number') if res_snap.exists else None

            if prev_num != number:
                print(f"Updating {market}: {prev_num} -> {number}")
                res_ref.set({
                    'number': number,
                    'date': date_str,
                    'declaredAt': firestore.SERVER_TIMESTAMP,
                    'autoSynced': True
                }, merge=True)

                # 2. Update History for Calendar & Chart
                doc_id = f"{month_year_str}_{date_str}_{market}"
                db.collection('results_history').document(doc_id).set({
                    'market': market,
                    'number': number,
                    'date': date_str,
                    'monthYear': month_year_str,
                    'timestamp': firestore.SERVER_TIMESTAMP,
                    'autoSynced': True
                }, merge=True)

        print("Sync Completed Successfully!")

    except Exception as e:
        print(f"Error during sync: {e}")

if __name__ == "__main__":
    fetch_and_sync()
