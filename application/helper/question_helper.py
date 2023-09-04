from application import mysql
from application.objects.question import Question


def get_questions_from_category(category):
    cursor = mysql.connect().cursor()
    cursor.execute('SELECT * FROM questions WHERE category=%s', (category,))
    question_list = []
    for question_id, question, answer, category in cursor.fetchall():
        question_list.append(Question(question_id, question, answer, category))
    return question_list


def add_question(question, answer, category):
    connection = mysql.connect()
    cursor = connection.cursor()
    cursor.execute('INSERT INTO questions (question, answer, category) VALUES (%s, %s, %s)', (question, answer, category))
    connection.commit()


def delete_question(question_id):
    cursor = mysql.connect().cursor()
    cursor.execute('DELETE FROM questions WHERE id=%s', (question_id,))
