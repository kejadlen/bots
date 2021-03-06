from base64 import b64decode
import logging
import os

import boto3

from tech_mottos import *

def decrypt(encrypted):
    return boto3.client('kms').decrypt(CiphertextBlob=b64decode(encrypted))

WORDNIK_API_KEY = decrypt(os.environ['WORDNIK_API_KEY'])['Plaintext']
TWITTER_API_KEY = decrypt(os.environ['TWITTER_API_KEY'])['Plaintext']
TWITTER_API_SECRET = decrypt(os.environ['TWITTER_API_SECRET'])['Plaintext']
TWITTER_ACCESS_TOKEN = decrypt(os.environ['TWITTER_ACCESS_TOKEN'])['Plaintext']
TWITTER_ACCESS_TOKEN_SECRET = decrypt(os.environ['TWITTER_ACCESS_TOKEN_SECRET'])['Plaintext']

def handler(event, context):
    logger = logging.getLogger()
    # logger.setLevel(logging.DEBUG)

    wordnik = Wordnik(WORDNIK_API_KEY)
    twitter = Twitter(
            TWITTER_API_KEY,
            TWITTER_API_SECRET,
            TWITTER_ACCESS_TOKEN,
            TWITTER_ACCESS_TOKEN_SECRET)

    tech_mottos = TechMottos(wordnik, twitter)
    return tech_mottos.tweet().text
