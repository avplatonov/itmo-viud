﻿using System;
using System.Collections.Generic;

namespace StackOverflow.Models
{
    public class Question
    {
        public Guid Id { get; set; }
        public int QuestionId { get; set; }
        public string Description { get; set; }
        public int Votes { get; set; }
        public int Views { get; set; }
        public List<string> Tags { get; set; }
    }
}