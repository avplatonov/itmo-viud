using System;
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
            var htmlParser = new StackOverflowParser();

            var questionsStream = new QuestionsStream(context, htmlParser);

            var questions = new List<Question>();

            await foreach (var question in questionsStream.GetQuestions("c%23"))
            {
                Console.WriteLine("WE GET A NEW QUESTION");
                questions.Add(question);
            }

            await using var fs = File.Create("questions.json");
            
            await JsonSerializer.SerializeAsync(fs, questions);
        }
    }
}
