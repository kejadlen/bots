from base64 import b64decode
import json
import logging
import os

import boto3

def decrypt(encrypted):
    return boto3.client('kms').decrypt(CiphertextBlob=b64decode(encrypted))

ACCESS_TOKEN = decrypt(os.environ['ACCESS_TOKEN'])['Plaintext']

class Slack:
    def __init__(self, access_token):
        self.access_token = access_token

def handler(event, context):
    alpha_bot = AlphaBot(slack)
    wrapper = json.loads(event['body'])
    return alpha_bot.handle(wrapper)
