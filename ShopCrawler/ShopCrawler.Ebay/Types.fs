module ShopCrawler.Ebay.Types

open System
open MongoDB.Bson.Serialization.Attributes

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

[<BsonIgnoreExtraElements>]
type Item =
    { itemId: int64
      timestamp: int64
      title: string
      category: Category
      url: Uri
      location: string
      price: float32
      condition: int64 }
    
