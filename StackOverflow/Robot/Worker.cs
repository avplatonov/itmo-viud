using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using AngleSharp;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using StackOverflow;
using StackOverflow.Models;
using StackOverflow.Parsers;

namespace Robot
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;

        public Worker(ILogger<Worker> logger)
        {
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var config = Configuration.Default.WithDefaultLoader();
            var context = BrowsingContext.New(config);
            var htmlParser = new StackOverflowParser();
            
            var questionsStream = new QuestionsStream(context, htmlParser);
            
            var questions = new List<Question>();
            
            while (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("Worker running at: {time}", DateTimeOffset.Now);
                _logger.LogInformation("Start crawling stackoverflow at: {time}", DateTimeOffset.Now);
                
                await foreach (var question in questionsStream.GetQuestions("c%23"))
                {
                    questions.Add(question);
                }
                
                _logger.LogInformation("Finishing crawling at: {time}", DateTimeOffset.Now);
                
                _logger.LogInformation("Start saving data at: {time}", DateTimeOffset.Now);

                await using (var fs = File.Create("questions.json"))
                {
                    await JsonSerializer.SerializeAsync(fs, questions);
                }
            
                _logger.LogInformation("Finishing saving data at: {time}", DateTimeOffset.Now);
                
                await Task.Delay(100000, stoppingToken);
            }
        }
    }
}
