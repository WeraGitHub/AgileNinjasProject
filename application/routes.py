from flask import render_template
from application import app
from application.helper.init_questions import create_html_question_list


@app.route('/')
@app.route('/home')
def home():
    title_name = "Quizlet"
    return render_template('home.html', title=title_name)


@app.route('/question_list')
def question_list():
    return create_html_question_list()
