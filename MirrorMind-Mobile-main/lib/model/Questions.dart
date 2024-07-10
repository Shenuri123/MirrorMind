class Question {
  final int id, answer;
  final String question;
  final List<String> options;

  Question({required this.id, required this.question, required this.answer, required this.options});
}

const List sample_data = [
  {
    "id": 1,
    "question": "What gas do plants absorb from the atmosphere during photosynthesis?",
    "options": ['Oxygen', ' Carbon monoxide', 'Nitrogen'],
    "answer": 0,
  },
  {
    "id": 2,
    "question": "Who wrote the famous play Romeo and Juliet?",
    "options": ['Charles Dickens', 'Mark Twain', 'William Shakespeare'],
    "answer": 1,
  },
  {
    "id": 3,
    "question": "Which planet is closest to the sun in our solar system?",
    "options": ['Venus', 'Earth', 'Mars', 'Mercury'],
    "answer": 2,
  },
  {
    "id": 4,
    "question":
        "What is the capital of France?",
    "options": ['London', 'Berlin', 'Madrid', 'Paris'],
    "answer": 3,
  },
];
