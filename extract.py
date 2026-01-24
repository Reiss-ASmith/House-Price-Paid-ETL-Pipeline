import requests

complete_data_url = "http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-complete.csv"

def download_complete_data_to_disk():
    file_path = "/data/pp-complete.csv"
    with requests.get(complete_data_url, stream=True, timeout=120) as response:
        response.raise_for_status()

        with open(file_path, "wb") as file:
            for chunk in response.iter_content(chunk_size=1024 * 1024):
                if chunk:
                    file.write(chunk)

