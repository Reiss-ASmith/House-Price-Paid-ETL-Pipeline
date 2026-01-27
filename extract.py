import requests
import logging 

log = logging.getLogger(__name__)

complete_data_url = "http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-complete.csv"
monthly_update_url = "http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-monthly-update-new-version.csv"

def download_complete_data_to_disk():
    log.info("Attempting to download complete-pp.csv to disk")
    file_path = "./data/pp-complete.csv"
    with requests.get(complete_data_url, stream=True, timeout=120) as response:
        response.raise_for_status()

        with open(file_path, "wb") as file:
            for chunk in response.iter_content(chunk_size=1024 * 1024):
                if chunk:
                    file.write(chunk)
    log.info("complete-pp.csv download complete")

def download_monthly_update():
    log.info("Attempting to download pp-monthly-update-new-version.csv to disk")
    file_path = "./data/pp-monthly-update-new-version.csv"
    with requests.get(monthly_update_url, stream=True, timeout=120) as response:
        response.raise_for_status()

        with open(file_path, "wb") as file:
            for chunk in response.iter_content(chunk_size=1024 * 1024):
                if chunk:
                    file.write(chunk)
    log.info("pp-monthly-update-new-version.csv download complete")