module ShopCrawler.Ebay.SaveToDB

open ShopCrawler.Ebay
open MongoDB.Driver
open MongoDB.Bson
open ShopCrawler.Ebay.Types
let dbInit =
    let connectionString = "mongodb://localhost"
    let client = new MongoClient(connectionString)
    let server = client.GetServer();
    let db = server.GetDatabase("test")
    db
    
let save collectionName (item: Item) =
    let collection = dbInit.GetCollection<Item>(collectionName)
    collection.Insert(item)

let saveItems items =
    for item in items do
        save "item" item