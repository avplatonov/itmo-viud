// Learn more about F# at http://fsharp.org

open System
open Hangfire.Mongo.Migration.Strategies
open Hangfire.Mongo.Migration.Strategies.Backup
open Microsoft.Extensions.Configuration
open Microsoft.Extensions.Hosting
open Microsoft.Extensions.DependencyInjection
open MongoDB.Driver
open Hangfire.Mongo
open Hangfire
open ShopCrawler.Ebay.Types
open ShopCrawler.Service
open ShopCrawler.Service.Types

[<EntryPoint>]
let main argv =
    Host.CreateDefaultBuilder(argv)
        .ConfigureServices(fun s ->
            let configuration = s.BuildServiceProvider().GetRequiredService<IConfiguration>()
            let mongoConnectionString = configuration.GetConnectionString("MongoDB")
            
            let mongoUrlBuilder = MongoUrlBuilder(mongoConnectionString)
            let mongoClient = MongoClient(mongoUrlBuilder.ToMongoUrl())
            
            let mongoOptions =
                MongoStorageOptions(
                    MigrationOptions = MongoMigrationOptions(
                        MigrationStrategy = MigrateMongoMigrationStrategy(),
                        BackupStrategy = CollectionMongoBackupStrategy()
                    ),
                    Prefix = "hangfire.mongo",
                    CheckConnection = true
                )

            s.AddHangfire(fun c ->
                c
                 .SetDataCompatibilityLevel(CompatibilityLevel.Version_170)
                 .UseSimpleAssemblyNameTypeSerializer()
                 .UseRecommendedSerializerSettings()
                 .UseMongoStorage(mongoClient, mongoUrlBuilder.DatabaseName, mongoOptions)
                |> ignore
             )
             .AddHangfireServer()
             |> ignore
            
            s.AddHostedService<CrawlerService>()
             .AddSingleton<MongoClient>(mongoClient)
             .AddSingleton<MongoUrlBuilder>(mongoUrlBuilder)
             .AddSingleton<FinderService>()
             .AddSingleton<JobHandlerService>()
             .Configure<JobsConfiguration>(configuration.GetSection("JobsConfiguration"))
             .Configure<EbayConfig>(configuration.GetSection("Ebay"))
            |> ignore

            
            ()
        )
        .Build()
        .Run()
    
    0
