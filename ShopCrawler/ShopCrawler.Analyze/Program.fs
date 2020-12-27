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

let client         = MongoClient(ConnectionString)
let db             = client.GetDatabase(DbName)
let testCollection = db.GetCollection<Item>(CollectionName)

let iphone11Price =
    let iphone11 = testCollection.Find(fun i -> i.title.ToLower().Contains("iphone 11") && i.title.ToLower().Contains("64")).ToEnumerable()
                   |> Seq.groupBy (fun i -> i.timestamp)
                   |> Seq.map (fun (k, v) -> k |> float |> DateTime.UnixEpoch.AddSeconds, v |> Seq.averageBy (fun i -> i.price))
                   
    iphone11
    |> Chart.Line
    |> Chart.WithTitle "Price IPhone 11 by timestamp"
    |> Chart.WithHeight 800
    
let iphone11LocationPrice =
        let iphone11L = testCollection.Find(fun i -> i.title.ToLower().Contains("iphone 11") && i.title.ToLower().Contains("64")).ToEnumerable()
                       |> Seq.distinctBy(fun i -> i.itemId) 
                       |> Seq.groupBy (fun i -> i.location)
                       |> Seq.map (fun (k, v) -> k, v |> Seq.length )
                       
        let iphone11P = testCollection.Find(fun i -> i.title.ToLower().Contains("iphone 11") && i.title.ToLower().Contains("64")).ToEnumerable()
                       |> Seq.distinctBy(fun i -> i.itemId) 
                       |> Seq.groupBy (fun i -> i.location)
                       |> Seq.map (fun (k, v) -> k, v |> Seq.averageBy (fun i -> i.price) |> int)
                       
        [iphone11L; iphone11P]
        |> Chart.Column
        |> Chart.WithTitle "Count IPhone 11 by location and avg price"
        |> Chart.WithHeight 800
        
let iphone11Location =
        let iphone11 = testCollection.Find(fun i -> i.title.ToLower().Contains("iphone 11") && i.title.ToLower().Contains("64")).ToEnumerable()
                       |> Seq.distinctBy(fun i -> i.itemId) 
                       |> Seq.groupBy (fun i -> i.location)
                       |> Seq.map (fun (k, v) -> k, v |> Seq.length )
        iphone11
        |> Chart.Column
        |> Chart.WithTitle "Count IPhone 11 by location"
        |> Chart.WithHeight 800
  
[<EntryPoint>]
let main argv =
    iphone11LocationPrice |> Chart.Show
    0

