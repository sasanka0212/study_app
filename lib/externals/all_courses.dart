import 'package:flutter/material.dart';
import 'package:study_app/classes/question.dart';

Map<String, Set<Map<String, Object>>> courseDetails = {
  "it": {
    {
      "id": "it01",
      "name": "System Design",
      "questions": {
        "Which one of the following is not a real time operating system?",
        "The operating system is responsible for?",
        "What are the characteristics of stack based IDS?",
        " In Unix, which system call creates the new process?",
        "The main memory accommodates?",
        "The growing phase is a phase in which?",
        "What is Address Binding?",
        "What is the advantage of dynamic loading?",
        "Which algorithm is defined in Time quantum?",
        "Which one of the following can not be scheduled by the kernel?",
      },
    },
    {
      "id": "it02",
      "name": "Operating System",
      "questions": {},
    },
    {
      "id": "it03",
      "name": "Computer Networks",
      "questions": {},
    },
    {
      "id": "it04",
      "name": "Database Management System",
      "questions": {},
    },
    {
      "id": "it05",
      "name": "Machine Learning",
      "questions": {},
    },
    {
      "id": "it06",
      "name": "Python Basics",
      "questions": {},
    },
  },
  "design": {
    {
      "id": "de01",
      "name": "Getting Started with Figma",
      "questions": {},
    },
    {
      "id": "de02",
      "name": "Adobe for Beginers",
      "questions": {},
    },
    {
      "id": "de03",
      "name": "CAD Advanced",
      "questions": {},
    },
  },
  "marketing": {
    {
      "id": "mr01",
      "name": "Social Media",
      "questions": {},
    },
    {
      "id": "mr02",
      "name": "Content Creation",
      "questions": {},
    },
    {
      "id": "mr03",
      "name": "Entreprenuership",
      "questions": {},
    },
  },
  "teaching": {
    {
      "id": "tc01",
      "name": "Computer Science",
      "questions": {},
    },
    {
      "id": "tc02",
      "name": "Physics",
      "questions": {},
    },
    {
      "id": "tc03",
      "name": "Geography",
      "questions": {},
    },
  },
  "medical": {
    {
      "id": "md01",
      "name": "Molicular Biology",
      "questions": {},
    },
    {
      "id": "md02",
      "name": "Ecology",
      "questions": {},
    },
    {
      "id": "md03",
      "name": "Bio Chemistry",
      "questions": {},
    },
  },
  "engineering": {
    {
      "id": "en02",
      "name": "Mechanical Engineering",
      "questions": {},
    },
    {
      "id": "en03",
      "name": "Automobile Engineering",
      "questions": {},
    },
    {
      "id": "en04",
      "name": "Electrical Engineering",
      "questions": {},
    },
  },
};

Map<String, List<Question>> questions = {
  "Operating System": [
    Question(
      "Which one of the following is not a real time operating system?", 
      ["VxWorks", "RTLinux", "Windows CE", "MS-DOS"],
      3,
    ),
    Question(
      "In Unix, which system call creates the new process?", 
      ["exec()", "fork()", "wait()", "exit()"],
      1,
    ),
    Question(
      "Thread stands for what?", 
      ["Lightweight process", "Lightweight os", "Heavyweight task", "None of the above"],
      0,
    ),
    Question(
      "Which algorithm is defined in Time quantum?", 
      ["SRTF", "FCFS", "PS", "RR"],
      3,
    ),
    Question(
      "Which one of the following can not be scheduled by the kernel?", 
      ["Kernel-level Thread", "User-level Thread", "Process", "Lightweight process"],
      1,
    ),
  ],
  "Computer Networks": [
    Question(
      "OSI stands for", 
      ["Object System Interface", "Object Service Item", "Open System Interface", "None of the above"],
      2,
    ),
  ],
  "Database Management System": [
    Question(
      "Which term best define a relation in DBMS ", 
      ["Table", "Column", "Row", "Index"], 
      0,
    ),
  ],
  "Python Basics": [
    Question(
      "List is type of?", 
      ["Index", "Variable", "Constant", "Data type"], 
      3,
    ),
  ],
  "Machine Learning": [
    Question(
      "Which neural network deals better with images?", 
      ["ANN", "RNN", "CNN", "LBPH"], 
      2,
    ),
  ],
  "System Design": [
    Question(
      "LLD is best suitable for?", 
      ["Manufacturing", "Design", "Debugging", "Coding"],
      1,
    ),
  ],
};

Map<String, int> correctOptions = {
  "Which one of the following is not a real time operating system?": 1,
  "In Unix, which system call creates the new process?": 2,
  "The growing phase is a phase in which?": 1,
  "Which algorithm is defined in Time quantum?": 3,
  "Which one of the following can not be scheduled by the kernel?": 3,
};
