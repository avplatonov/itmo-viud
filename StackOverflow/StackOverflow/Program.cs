using System;
using System.Threading.Tasks;
using AngleSharp;
using StackOverflow.Parsers;

namespace StackOverflow
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var config = Configuration.Default.WithDefaultLoader();
            var context = BrowsingContext.New(config);
            
            foreach (var url in QuestionsQueue.QuestionsUrls)
            {
                
                var document = await context.OpenAsync(url);
                
                var questionParser = new QuestionParser();
                var answers = questionParser.ParseAnswers(document);

                // var question = questionParser.ParseQuestion(document);
                //
                // Console.WriteLine($"Question id = {question.QuestionId} and description = {question.Description} and votes = {question.Votes} and views = {question.Views}");
                // Console.WriteLine("Tags: ");
                // foreach (var questionTag in question.Tags)
                // {
                //     Console.WriteLine(questionTag);
                // }
            }
        }
    }
}
