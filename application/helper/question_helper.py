# Import necessary modules and classes
from application import mysql  # Import the 'mysql' object from the 'application' module
from application.objects.question import Question  # Import the 'Question' class from the 'application.objects.question' module

# Define a function to retrieve questions from a specific category in the database
def get_questions_from_category_from_db(category):
    # Create a cursor object to interact with the database
    cursor = mysql.connect().cursor()

    # Execute a SQL query to select all rows from the 'questions' table where the 'category' matches the provided category
    cursor.execute('SELECT * FROM questions WHERE category=%s', (category,))

    # Initialize an empty list to store the retrieved questions
    question_list = []

    # Iterate through the result set returned by the query
    for question_id, question, answer, category in cursor.fetchall():
        # Create a 'Question' object with the retrieved data and append it to the 'question_list'
        question_list.append(Question(question_id, question, answer, category))

    # Return the list of questions
    return question_list

# Define a function to retrieve all questions from the database
def get_all_questions_from_db():
    # Create a cursor object to interact with the database
    cursor = mysql.connect().cursor()

    # Execute a SQL query to select all rows from the 'questions' table
    cursor.execute('SELECT * FROM questions')

    # Initialize an empty list to store the retrieved questions
    question_list = []

    # Iterate through the result set returned by the query
    for question_id, question, answer, category in cursor.fetchall():
        # Create a 'Question' object with the retrieved data and append it to the 'question_list'
        question_list.append(Question(question_id, question, answer, category))

    # Return the list of questions
    return question_list

# Define a function to add a new question to the database
def add_question_to_db(question, answer, category):
    # Establish a database connection
    connection = mysql.connect()

    # Create a cursor object to interact with the database
    cursor = connection.cursor()

    # Execute a SQL query to insert a new row into the 'questions' table with the provided question, answer, and category
    cursor.execute('INSERT INTO questions (question, answer, category) VALUES (%s, %s, %s)', (question, answer, category))

    # Commit the changes to the database
    connection.commit()

# Define a function to update an existing question in the database
def update_question_in_db(id, question, answer, category):
    # Establish a database connection
    connection = mysql.connect()

    # Create a cursor object to interact with the database
    cursor = connection.cursor()

    # Execute a SQL query to update the 'questions' table with the provided question, answer, and category where the 'id' matches
    cursor.execute('UPDATE questions SET question=%s, answer=%s, category=%s WHERE id=%s', (question, answer, category, id))

    # Commit the changes to the database
    connection.commit()

# Define a function to delete a question from the database by its ID
def delete_question_from_db(question_id):
    # Establish a database connection
    connection = mysql.connect()

    # Create a cursor object to interact with the database
    cursor = connection.cursor()

    # Execute a SQL query to delete a row from the 'questions' table where the 'id' matches the provided 'question_id'
    cursor.execute('DELETE FROM questions WHERE id=%s', (question_id,))

    # Commit the changes to the database
    connection.commit()
