from flask import render_template, request
from application import app
from application.helper.question_helper import *


@app.route('/')
@app.route('/home')
def home():
    return render_template('home.html')


@app.route('/question/<category>/<q_number>')   #  http://127.0.0.1:5000/question/aws/2
def question(category, q_number):
    questions = get_questions_from_category(category)
    question = questions[int(q_number)-1]
    return render_template('question.html', question=question, q_number=int(q_number), q_total=len(questions))

@app.route("/question/add", methods=['GET', 'POST'])
def add_question():
    if request.method == 'GET':
        return render_template('add_question.html')
    elif request.method == 'POST':
        question = request.form['question']
        answer = request.form['answer']
        if answer == '' or question == '':
            return render_template('add_question_response.html', message="Answer and Question are required fields")
        category = request.form['category']
        add_question_to_db(question, answer, category)
        return render_template('add_question_response.html', message="Success!")


@app.route("/question/view_all")
def view_all_questions():
    questions = get_all_questions_from_db()
    return render_template("view_all_questions.html", questions=questions)

@app.route("/question/edit/<question_id>", methods=['POST'])
def edit_question(question_id):
    question = request.form['question']
    answer = request.form['answer']
    category = request.form['category']
    update_question_in_db(question_id, question, answer, category)
    return render_template('add_question_response.html', message="Success!")


@app.route("/question/delete/<question_id>", methods=['POST'])
def delete_question(question_id):
    delete_question_from_db(question_id)
    return render_template('add_question_response.html', message="Success!")
