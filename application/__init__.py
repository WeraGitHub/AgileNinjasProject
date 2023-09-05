import os

from flask import Flask
from flaskext.mysql import MySQL
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.config['MYSQL_DATABASE_HOST'] = os.environ['MYSQL_DATABASE_HOST']
app.config['MYSQL_DATABASE_PORT'] = 3306
app.config['MYSQL_DATABASE_USER'] = os.environ['MYSQL_DATABASE_USER']
app.config['MYSQL_DATABASE_PASSWORD'] = os.environ['MYSQL_DATABASE_PASSWORD']
app.config['MYSQL_DATABASE_DB'] = os.environ['MYSQL_DATABASE_DB']

mysql = MySQL(app)

from application import routes
