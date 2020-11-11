using System.Collections.Generic;
using AngleSharp.Dom;
using StackOverflow.Models;

namespace StackOverflow.Abstracts
{
    public interface IParser
    {
        Question ParseQuestion(IDocument document);
        List<string> ParseDiscussions(IDocument document);
    }
}