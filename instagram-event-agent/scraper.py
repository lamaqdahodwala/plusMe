import os
import requests
from pathlib import Path
from dotenv import load_dotenv

env_path = Path(__file__).resolve().parent / ".env"
load_dotenv(env_path)

ACCESS_TOKEN = os.getenv("INSTAGRAM_ACCESS_TOKEN")

def test_page_access():
    url = "https://graph.facebook.com/v24.0/me/accounts"

    params = {
        "fields": "id,name,tasks",
        "summary": "true",
        "access_token": ACCESS_TOKEN
    }

    response = requests.get(url, params=params)

    print("Status code:", response.status_code)
    print("Meta response:", response.text)


if __name__ == "__main__":
    test_page_access()