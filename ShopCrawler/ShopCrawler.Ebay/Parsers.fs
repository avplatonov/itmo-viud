﻿module ShopCrawler.Ebay.Parsers

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
      timestamp = DateTimeOffset(DateTime.Now).ToUnixTimeSeconds()
      title = jsonValue?title.AsSingleItem.AsString()
      category = parseCategory jsonValue?primaryCategory.AsSingleItem
      url = jsonValue?viewItemURL.AsSingleItem.AsString() |> Uri
      location = jsonValue?location.AsSingleItem.AsString()
      price = jsonValue?sellingStatus.AsSingleItem?convertedCurrentPrice.AsSingleItem?__value__.AsString() |> float32
      condition = jsonValue?condition.AsSingleItem?conditionId.AsSingleItem.AsString() |> int64 }