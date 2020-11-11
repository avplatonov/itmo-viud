﻿using System;
using System.Collections.Generic;
using System.Linq;
using AngleSharp.Dom;
using StackOverflow.Abstracts;
using StackOverflow.Models;

namespace StackOverflow.Parsers
{
    public class QuestionParser : IParser
    {
        public Question ParseQuestion(IDocument document)
        {
            var url = int.Parse(document.Url.Split("/")[4]);
            
            var description = document.QuerySelectorAll("#question-header")[0].Children[0].Children[0].Text();
            
            var votes = int.Parse(document.QuerySelectorAll(".js-vote-count")[0].Text());
            
            var views = int.Parse(document.QuerySelectorAll(".inner-content.clearfix")[0].Children[1].Children[2].GetAttribute("title").Split()[1].Replace(",", ""));

            var tags = document
                .QuerySelectorAll(".post-tag")
                .Select(e => e.Text())
                .Distinct()
                .ToList();
            
            return new Question
            {
                QuestionId = url,
                Description = description,
                Votes = votes,
                Views = views,
                Tags = tags
            };
        }

        public List<Answer> ParseAnswers(IDocument document)
        {
            foreach (var element in document.QuerySelectorAll(".s-prose.js-post-body"))
            {
                // Console.WriteLine(element.Text());
            }

            return null;
        }
    }
}