// Learn more about F# at http://fsharp.org

open System

open MongoDB.Bson
open MongoDB.Driver
open MongoDB.Driver.Builders
open MongoDB.FSharp
open ShopCrawler.Ebay.Types
open XPlot.GoogleCharts

[<Literal>]
let ConnectionString = "mongodb://localhost"

[<Literal>]
let DbName = "shopCrawler"

[<Literal>]
let CollectionName = "items"

let client = MongoClient(ConnectionString)
let db = client.GetDatabase(DbName)
let testCollection = db.GetCollection<Item>(CollectionName)


let inline epochToDate x =
    x |> float |> DateTime.UnixEpoch.AddSeconds

let price items =
    items
    |> Seq.groupBy (fun i -> i.timestamp)
    |> Seq.map (fun (k, v) -> epochToDate k, v |> Seq.averageBy (fun i -> i.price) |> float)

let candlesticks (period: int) title items =
    items
    |> Seq.groupBy (fun i -> int i.timestamp / period)
    |> Seq.mapi (fun i (_, v) ->
        let prices =
            v
            |> Seq.map (fun x -> x.price)
            |> Seq.sort
            |> List.ofSeq

        let count = List.length prices

        sprintf "%s %i" title (i + 1),
        Seq.min prices,
        prices |> Seq.skip (count / 10) |> Seq.head,
        prices |> Seq.skip (count / 10 * 9) |> Seq.head,
        Seq.max prices)
    |> List.ofSeq

let macbook year =
    testCollection
        .Find(fun i ->
        i.title.ToLower().Contains("macbook pro 15")
        && i.title.ToLower().Contains(year.ToString()))
        .ToEnumerable()

let iphone11 () =
    testCollection
        .Find(fun i -> i.title.ToLower().Contains("iphone 11"))
        .ToEnumerable()

let iphones () =
    testCollection
        .Find(fun i -> i.title.ToLower().Contains("iphone"))
        .ToEnumerable()

let show = Chart.WithHeight 700 >> Chart.Show

let macBooksByWeeks years =
    years
    |> Seq.map (macbook >> candlesticks (60 * 60 * 24 * 7) "Week")
    |> Chart.Candlestick
    |> Chart.WithLegend false
    |> Chart.WithTitle "MacBooks pro 15 by weeks prices"
    |> show

let macBooksByDays years =
    years
    |> Seq.map (macbook >> candlesticks (60 * 60 * 24) "Day")
    |> Chart.Candlestick
    |> Chart.WithLegend false
    |> Chart.WithTitle "MacBooks pro 15 by days prices"
    |> show


let iphone11PricesAvg () =
    iphone11 ()
    |> price
    |> Chart.Line
    |> Chart.WithOptions(Options(curveType = "function"))
    |> Chart.WithTitle "iPhone 11 price"
    |> show

let iphone11pricesCalendar () =
    iphone11 () |> price |> Chart.Calendar |> show

let allIphoneAdsCount () =
    iphones ()
    |> Seq.distinctBy (fun i -> i.itemId)
    |> Seq.groupBy (fun i ->
        let date = epochToDate i.timestamp
        date.DayOfWeek, date.Hour)
    |> Seq.map (fun ((day, hour), items) ->
        "", int day, hour, Seq.length items)
    |> Chart.Bubble
    |> Chart.WithOptions
        (Options
            (title = "New iPhones ads count",
             hAxis = Axis(title = "Day of week"),
             vAxis = Axis(title = "Hour"),
             bubble = Bubble(textStyle = TextStyle(fontSize = 11))))
    |> Chart.WithLabels [ "id"
                          "Day of the week"
                          "Hour"
                          "Ads count" ]
    |> show

let allIphoneAdsByDayOfWeek () =
    iphones ()
    |> Seq.distinctBy (fun i -> i.itemId)
    |> Seq.groupBy (fun i -> (epochToDate i.timestamp).DayOfWeek)
    |> Seq.map (fun (k, items) -> k.ToString(), Seq.length items)
    |> Chart.Bar
    |> Chart.WithLabel "New by day"
    |> show


[<EntryPoint>]
let main _ =
    allIphoneAdsByDayOfWeek ()

    0
    