using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using AngleSharp;
using StackOverflow.Abstracts;
using StackOverflow.Models;

namespace StackOverflow
{
    public class QuestionsStream : IQuestionsStream
    {
        private readonly IBrowsingContext _context;
        private readonly IHtmlParser _parser;
        
        private readonly HttpClient _client = new HttpClient();

        public QuestionsStream(IBrowsingContext context, IHtmlParser parser)
        {
            _context = context;
            _parser = parser;
        }

        public async IAsyncEnumerable<Question> GetQuestions(string tag)
        {
            var url = $"https://api.stackexchange.com/2.2/tags/{tag}/faq?site=stackoverflow";

            var response = await _client.GetAsync(url);
            
            response.EnsureSuccessStatusCode();

            // var readAsStringAsync = await response.Content.ReadAsStringAsync();
            // Console.WriteLine(readAsStringAsync);

            var jsonUtf8Bytes = await response.Content.ReadAsByteArrayAsync();

            var faq = ParseTagsFAQ(jsonUtf8Bytes);
            
            foreach (var questionId in faq)
            {
                var document = await _context.OpenAsync($"https://stackoverflow.com/questions/{questionId}");
            
                var question = _parser.ParseQuestion(document);
                question.Discussions = _parser.ParseDiscussions(document);

                yield return question;
            }
        }

        private static List<string> ParseTagsFAQ(byte[] jsonUtf8Bytes)
        {
            // jsonUtf8Bytes = jsonUtf8Bytes[1..];
            
            // Console.WriteLine(jsonUtf8Bytes[0]);
            
            // new JsonReaderOptions
            // {
            //     
            // }
            var reader = new Utf8JsonReader(jsonUtf8Bytes);
            
            using var jsonDocument = JsonDocument.ParseValue(ref reader);
            
            return jsonDocument.RootElement
                .GetProperty("items")
                .EnumerateArray()
                .Select(e => e
                    .GetProperty("question_id")
                    .GetString())
                .ToList();
        }
    }
}