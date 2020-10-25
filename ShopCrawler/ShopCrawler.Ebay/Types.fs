module ShopCrawler.Ebay.Types

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
      BaseUrl: string }
   