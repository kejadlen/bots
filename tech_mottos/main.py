import json
import os

import boto3

from tech_mottos import TechMottos, Twitter, Wordnik


def handler(event, context):
    # logger = logging.getLogger()
    # logger.setLevel(logging.DEBUG)

    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager")
    secret_id = os.environ["SECRET_ID"]
    secret_value = client.get_secret_value(SecretId=secret_id)
    secret = json.loads(secret_value["SecretString"])

    wordnik_api_key = secret["wordnik"]["api_key"]
    twitter_api_key = secret["twitter"]["api_key"]
    twitter_api_secret = secret["twitter"]["api_secret"]
    twitter_access_token = secret["twitter"]["access_token"]
    twitter_access_token_secret = secret["twitter"]["access_token_secret"]

    wordnik = Wordnik(wordnik_api_key)
    twitter = Twitter(
        twitter_api_key,
        twitter_api_secret,
        twitter_access_token,
        twitter_access_token_secret,
    )

    tech_mottos = TechMottos(wordnik, twitter)
    return tech_mottos.tweet().text
