module ShopCrawler.Ebay.Client

open Types

let build config token =
    { ApiToken = token
      BaseUrl = config.ApiBaseUrl }