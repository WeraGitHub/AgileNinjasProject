# Import necessary modules and functions from Flask and the application
from flask import render_template, request  # Import Flask functions for rendering templates and handling HTTP requests
from application import app  # Import the 'app' instance from the 'application' module
from application.helper.question_helper import *  # Import functions from the 'question_helper' module


# Define a route for the home page
@app.route('/')
@app.route('/home')
def home():
    return render_template('home.html')  # Render the 'home.html' template when accessing the root or '/home' URL


# Define a route for displaying a specific question based on category and question number
@app.route('/question/<category>/<q_number>')
def question(category, q_number):
    # Retrieve a list of questions from a specific category from the database
    questions = get_questions_from_category_from_db(category)

    # Get the question at the specified question number (index)
    question = questions[int(q_number) - 1]

    # Render the 'question.html' template and pass the question data, question number, and total number of questions
    return render_template('question.html', question=question, q_number=int(q_number), q_total=len(questions))


# Define a route for adding a new question
@app.route("/question/add", methods=['GET', 'POST'])
def add_question():
    if request.method == 'GET':
        return render_template(
            'add_question.html')  # Render the 'add_question.html' form when accessing via GET request

    elif request.method == 'POST':
        # Retrieve question, answer, and category data from the form submission
        question = request.form['question']
        answer = request.form['answer']

        # Check if both answer and question fields are not empty
        if answer == '' or question == '':
            return render_template('add_question_response.html', message="Answer and Question are required fields")

        category = request.form['category']

        # Add the new question to the database
        add_question_to_db(question, answer, category)

        # Render a response template with a success message
        return render_template('add_question_response.html', message="Success!")


# Define a route for viewing all questions
@app.route("/question/view_all")
def view_all_questions():
    # Retrieve a list of all questions from the database
    questions = get_all_questions_from_db()

    # Render the 'view_all_questions.html' template and pass the list of questions
    return render_template("view_all_questions.html", questions=questions)


# Define a route for editing a question by its ID
@app.route("/question/edit/<question_id>", methods=['POST'])
def edit_question(question_id):
    # Retrieve updated question, answer, and category data from the form submission
    question = request.form['question']
    answer = request.form['answer']
    category = request.form['category']

    # Update the question in the database using its ID
    update_question_in_db(question_id, question, answer, category)

    # Render a response template with a success message
    return render_template('add_question_response.html', message="Success!")


# Define a route for deleting a question by its ID
@app.route("/question/delete/<question_id>", methods=['POST'])
def delete_question(question_id):
    # Delete the question from the database using its ID
    delete_question_from_db(question_id)

    # Render a response template with a success message
    return render_template('add_question_response.html', message="Success!")
