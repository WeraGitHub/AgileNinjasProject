from flask import render_template
from application import app
from application.helper.init_questions import create_html_question_list


@app.route('/')
@app.route('/home')
def home():
    return render_template('home.html')


@app.route('/question/<category>/<q_number>')   #  http://127.0.0.1:5000/question/aws/2
def question(category, q_number):
    return render_template('question.html', category=category, q_number=q_number)


@app.route('/question_list')
def question_list():
    return create_html_question_list()
