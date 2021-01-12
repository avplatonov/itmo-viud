namespace ShopCrawler.Service

open System.Threading
open Hangfire
open Microsoft.Extensions.Hosting
open System.Threading.Tasks
open Microsoft.Extensions.Options
open ShopCrawler.Service.Types

type CrawlerService (scheduleOptions: IOptions<JobsConfiguration>) =
    let schedule = scheduleOptions.Value.Schedule
    
    interface IHostedService with
        member s.StartAsync (_: CancellationToken) =
            for job in schedule do
                RecurringJob.AddOrUpdate<JobHandlerService>(job.JobName, (fun (js: JobHandlerService) -> js.FindAndSave(job.Keywords, job.Category)), job.Cron)
            
            Task.CompletedTask
            
        member s.StopAsync (_: CancellationToken) = Task.CompletedTask

