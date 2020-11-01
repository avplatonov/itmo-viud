module ShopCrawler.Service.Types

[<CLIMutable>]
type ScheduleItem = {
    Cron: string
    Keywords: string array
    Category: string
    JobName: string
}

[<CLIMutable>]
type JobsConfiguration = {
    Schedule: ScheduleItem array
}

