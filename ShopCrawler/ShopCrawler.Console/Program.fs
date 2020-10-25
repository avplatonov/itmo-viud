// Learn more about F# at http://fsharp.org

open System
open ShopCrawler.Logic.API

[<EntryPoint>]
let main argv =
    let appid = "-FindingD-PRD-fc9062648-8a125721"
    printfn "Hello World from F#!"
    Console.Write(getRequestByKeywords appid "iphone")
    0 // return an integer exit code
