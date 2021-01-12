using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
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
            
            var responseStream = await _client.GetStreamAsync(url);

            await using (var decompressedFileStream = File.Create("faq.json"))
            {
                await using (var decompressionStream = new GZipStream(responseStream, CompressionMode.Decompress))
                {
                    await decompressionStream.CopyToAsync(decompressedFileStream);
                }
            }

            var text = await File.ReadAllTextAsync("faq.json");

            var jsonUtf8Bytes = Encoding.UTF8.GetBytes(text);

            var faq = ParseTagsFAQ(jsonUtf8Bytes);
            
            foreach (var questionId in faq)
            {
                var document = await _context.OpenAsync($"https://stackoverflow.com/questions/{questionId}");
            
                var question = _parser.ParseQuestion(document);
                question.Discussions = _parser.ParseDiscussions(document);

                yield return question;
            }
        }

        private static List<int> ParseTagsFAQ(byte[] jsonUtf8Bytes)
        {
            var reader = new Utf8JsonReader(jsonUtf8Bytes);
            
            using var jsonDocument = JsonDocument.ParseValue(ref reader);
            
            return jsonDocument.RootElement
                .GetProperty("items")
                .EnumerateArray()
                .Select(e => e
                    .GetProperty("question_id")
                    .GetInt32())
                .ToList();
        }
    }
}