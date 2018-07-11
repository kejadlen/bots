import json
import logging

class AlphaBot:
    def __init__(self, slack):
        self.slack = slack

    def handle(self, wrapper):
        logger = logging.getLogger()
        logger.setLevel(logging.DEBUG)
        logger.debug(wrapper)

        if wrapper['type'] == 'url_verification':
            return {
                'statusCode': 200,
                'body': json.dumps({'challenge': wrapper['challenge']})
            }
        elif wrapper['type'] == 'event_callback':
            event = wrapper['event']
            logger.debug(event)
            # if event['type'] != 'message' && event['channel'] != 'C4C959YHF'

        return {
            'statusCode': 200,
        }

