module ShopCrawler.Ebay.Types

[<CLIMutable>]
type EbayConfig =
    { ClientId: string
      ClientSecret: string
      BaseUrl: string
      Scopes: string list }
    
type ApiToken =
    { Token: string }
   