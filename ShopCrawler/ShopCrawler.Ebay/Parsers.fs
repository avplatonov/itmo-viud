module ShopCrawler.Ebay.Parsers

open System
open FSharp.Data
open Types

open FSharp.Data.JsonExtensions

type JsonValue with
    member x.AsSingleItem =
        x.AsArray().[0]

let parseCategory jsonValue =    
    { id = jsonValue?categoryId.AsSingleItem.AsString() |> int64
      name = jsonValue?categoryId.AsSingleItem.AsString() }
    
let parseItem jsonValue =
    { itemId = jsonValue?itemId.AsSingleItem.AsString() |> int64
      title = jsonValue?title.AsSingleItem.AsString()
      category = parseCategory jsonValue?primaryCategory.AsSingleItem
      image = jsonValue?galleryURL.AsSingleItem.AsString() |> Uri
      url = jsonValue?galleryURL.AsSingleItem.AsString() |> Uri
      location = jsonValue?location.AsSingleItem.AsString()
      price = jsonValue?sellingStatus.AsSingleItem?convertedCurrentPrice.AsSingleItem?__value__.AsString() |> float32
      condition = jsonValue?condition.AsSingleItem?conditionId.AsSingleItem.AsString() |> int64 }

