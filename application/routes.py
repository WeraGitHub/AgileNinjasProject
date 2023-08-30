from flask import render_template
from application import app


@app.route('/')
@app.route('/home')
def home():
    title_name = "Quizlet"
    return render_template('home.html', title=title_name)
