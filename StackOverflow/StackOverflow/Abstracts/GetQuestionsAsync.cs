using System.Collections.Generic;
using StackOverflow.Models;

namespace StackOverflow.Abstracts
{
    public interface IQuestionsStream
    {
        IAsyncEnumerable<Question> GetQuestions(string tag);
    }
}