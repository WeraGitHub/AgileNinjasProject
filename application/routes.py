from flask import render_template
from application import app
from application.helper.question_helper import get_questions_from_category


@app.route('/')
@app.route('/home')
def home():
    return render_template('home.html')


@app.route('/question/<category>/<q_number>')   #  http://127.0.0.1:5000/question/aws/2
def question(category, q_number):
    questions = get_questions_from_category(category)
    question = questions[int(q_number)-1]
    return render_template('question.html', question=question, q_number=q_number, q_total=len(questions))
