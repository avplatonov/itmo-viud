module ShopCrawler.Ebay.Providers

open FSharp.Data

type TokenResponse = JsonProvider<""" {"access_token": "token", "expires_in": 7200, "token_type": "Application Access Token"} """>
