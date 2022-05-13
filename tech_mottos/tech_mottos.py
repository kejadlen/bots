#!/usr/bin/env python

import logging
import os
import random

import inflection
from requests import Session
from requests_oauthlib import OAuth1Session


class Wordnik:
    def __init__(self, api_key):
        self.session = Session()
        self.session.params = {"api_key": api_key}

    def random_words(self, partOfSpeech, minCorpusCount=1000):
        params = {"includePartOfSpeech": partOfSpeech, "minCorpusCount": 1000}
        resp = self.session.get(
            "https://api.wordnik.com/v4/words.json/randomWords", params=params
        )
        json = resp.json()
        return [word["word"] for word in json]


class Twitter:
    def __init__(self, api_key, api_secret, access_token, access_token_secret):
        self.session = OAuth1Session(
            api_key,
            client_secret=api_secret,
            resource_owner_key=access_token,
            resource_owner_secret=access_token_secret,
        )

    def post(self, status):
        data = {"status": status}
        return self.session.post(
            "https://api.twitter.com/1.1/statuses/update.json", data=data
        )


class TechMottos:
    def __init__(self, wordnik, twitter):
        self.wordnik = wordnik
        self.twitter = twitter

    def tweet(self):
        logger = logging.getLogger()
        motto = self.motto()
        logger.debug("Motto: %s" % motto)
        response = self.twitter.post(motto)
        logger.debug("Response: %s" % response)
        return response

    def motto(self):
        nouns = self.wordnik.random_words(partOfSpeech="noun")
        verbs = self.wordnik.random_words(partOfSpeech="verb-transitive")
        adverbs = self.wordnik.random_words(partOfSpeech="adverb")

        [verb_1, verb_2] = random.sample(verbs, 2)
        adverb = random.choice(adverbs)
        noun = inflection.pluralize(random.choice(nouns))
        return " ".join([verb_1, adverb, "and", verb_2, noun]).capitalize()


if __name__ == "__main__":
    wordnik = Wordnik(os.environ["WORDNIK_API_KEY"])
    twitter = Twitter(
        os.environ["TWITTER_API_KEY"],
        os.environ["TWITTER_API_SECRET"],
        os.environ["TWITTER_ACCESS_TOKEN"],
        os.environ["TWITTER_ACCESS_TOKEN_SECRET"],
    )
    tech_mottos = TechMottos(wordnik, twitter)
    logging.basicConfig(level=logging.DEBUG)
    print(tech_mottos.motto())
    # tech_mottos.tweet()
