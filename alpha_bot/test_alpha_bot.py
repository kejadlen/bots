import json
import unittest
from unittest.mock import Mock

from alpha_bot import AlphaBot

class TestHandler(unittest.TestCase):

    def setUp(self):
        self.slack = Mock()
        self.alpha_bot = AlphaBot(self.slack)

    def test_challenge(self):
        wrapper = dict(type='url_verification', challenge='foobar')

        response = self.alpha_bot.handle(wrapper)

        self.assertEqual(response['statusCode'], 200)
        self.assertEqual(json.loads(response['body'])['challenge'], 'foobar')

    def test_message(self):
        wrapper = json.loads("""
            {
                "token": "one-long-verification-token",
                "team_id": "T061EG9R6",
                "api_app_id": "A0PNCHHK2",
                "event": {
                    "type": "message",
                    "channel": "C024BE91L",
                    "user": "U2147483697",
                    "text": "Live long and prospect.",
                    "ts": "1355517523.000005",
                    "event_ts": "1355517523.000005",
                    "channel_type": "channel"
                },
                "type": "event_callback",
                "authed_teams": [
                    "T061EG9R6"
                ],
                "event_id": "Ev0PV52K21",
                "event_time": 1355517523
            }""")

        response = self.alpha_bot.handle(wrapper)

        self.assertEqual(response['statusCode'], 200)

if __name__ == '__main__':
    unittest.main()
