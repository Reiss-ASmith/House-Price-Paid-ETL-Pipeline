import requests
from db import get_connection
from contextlib import contextmanager

complete_data_url = "http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-complete.csv"

@contextmanager
def get_complete_data_stream():
    with requests.get(complete_data_url, stream=True, timeout=120) as response:
        response.status_code
        yield response

