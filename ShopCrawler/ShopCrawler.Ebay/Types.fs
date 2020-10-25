module ShopCrawler.Ebay.Types

open System

[<CLIMutable>]
type EbayConfig =
    { ClientId: string
      ClientSecret: string
      AuthBaseUrl: string
      ApiBaseUrl: string
      Scopes: string[] }
    
type ApiToken =
    { Token: string }
    
type Client =
    { ApiToken: ApiToken
      AppName: string
      BaseUrl: string }
   
type Category =
    { id: int64
      name: string }
   
type Item =
    { itemId: int64
      title: string
      category: Category
      image: Uri
      url: Uri }