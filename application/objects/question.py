class Question:
    """
    A class representing a question with its answer and category.
    """

    def __init__(self, question_id, question, answer, category):
        """
        Initializes a Question instance.

        Args:
            question_id (int): The ID of the question.
            question (str): The text of the question.
            answer (str): The answer to the question.
            category (str): The category of the question.
        """
        self._question_id = question_id  # Store the question id
        self._question = question  # Store the question text
        self._answer = answer  # Store the answer to the question
        self._category = category  # Store the category of the question

    def get_question(self):
        """
        Returns the text of the question.

        Returns:
            str: The question text.
        """
        return self._question

    def get_answer(self):
        """
        Returns the answer to the question.

        Returns:
            str: The answer.
        """
        return self._answer

    def get_category(self):
        """
        Returns the category of the question.

        Returns:
            str: The category.
        """
        return self._category

    def get_question_id(self):
        """
        Returns the ID of the question.

        Returns:
            int: The question ID.
        """
        return self._question_id
