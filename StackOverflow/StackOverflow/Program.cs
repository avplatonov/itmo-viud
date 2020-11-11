using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;
using AngleSharp;
using StackOverflow.Models;
using StackOverflow.Parsers;

namespace StackOverflow
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var config = Configuration.Default.WithDefaultLoader();
            var context = BrowsingContext.New(config);

            var questions = new List<Question>();

            foreach (var url in QuestionsQueue.QuestionsUrls)
            {
                
                var document = await context.OpenAsync(url);
                
                var questionParser = new StackOverflowParser();
                
                var question = questionParser.ParseQuestion(document);
                question.Discussions = questionParser.ParseDiscussions(document);
                
                questions.Add(question);
            }

            await using var fs = File.Create("questions.json");
            
            await JsonSerializer.SerializeAsync(fs, questions);
        }
    }
}
