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
    
type ItemAdvanced =
    { itemId: int64
      timestamp: int64
      title: string
      category: Category
      location: string
      price: float32
      condition: int64 }
    
