namespace ShopCrawler.Service

open Microsoft.Extensions.Logging
open MongoDB.Driver

type JobHandlerService (finder: FinderService, mongoClient: MongoClient, mongoUrl: MongoUrlBuilder, logger: ILogger<JobHandlerService>) =
    let database = mongoClient.GetDatabase(mongoUrl.DatabaseName)
    let itemsCollection = database.GetCollection "items"
    
    member public x.FindAndSave (keywords, category) =
        finder.Find keywords category
        |> function
        | Ok items -> itemsCollection.InsertMany(items)
        | Error e -> logger.LogError (sprintf "Error, getting items: %s" e)
