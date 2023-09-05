import unittest

from question import Question


class TestQuestion(unittest.TestCase):
    """
    Test cases for the Question class.
    """

    def test_init(self):
        """
        Test the initialization of a Question instance.
        """
        question = Question(1, "What is the capital of France?", "Paris", "Geography")
        self.assertEqual(question.get_question(), "What is the capital of France?")
        self.assertEqual(question.get_answer(), "Paris")
        self.assertEqual(question.get_category(), "Geography")
        self.assertEqual(question.get_question_id(), 1)

    def test_get_question(self):
        """
        Test the get_question() method.
        """
        question = Question(1, "What is the capital of France?", "Paris", "Geography")
        self.assertEqual(question.get_question(), "What is the capital of France?")

    def test_get_answer(self):
        """
        Test the get_answer() method.
        """
        question = Question(1, "What is the capital of France?", "Paris", "Geography")
        self.assertEqual(question.get_answer(), "Paris")

    def test_get_category(self):
        """
        Test the get_category() method.
        """
        question = Question(1, "What is the capital of France?", "Paris", "Geography")
        self.assertEqual(question.get_category(), "Geography")

    def test_get_question_id(self):
        """
        Test the get_question_id() method.
        """
        question = Question(1, "What is the capital of France?", "Paris", "Geography")
        self.assertEqual(question.get_question_id(), 1)


if __name__ == "__main__":
    unittest.main()
