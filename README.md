# AgileNinjasProject


## Getting Started locally

1. Clone the repository:
`git clone https://github.com/WeraGitHub/AgileNinjasProject.git`

3. Navigate to the project directory:
`cd AgileNinjasProject`

4. Install the required packages:
`pip install -r requirements.txt`
    use pip3 on Mac: `pip3 install -r requirements.txt` 

5. Start the application:
`python app.py` or `python3 app.py`

   Alternatively you can manually navigate to the app.py file in your IDE and run it from here.

7. Open your web browser and go to http://localhost:5000.


For this application to work properly, you need to connect to a mysql database with table called 'questions'. Best option is to run a mysql container in docker.
1. Make sure you have Docker Desktop on your computer
2. Run this command in your terminal `docker run -d -p 3306:3306 --name mysql-db -e MYSQL_ROOT_PASSWORD=password mysql:latest`
3. To create a 'mydatabase' with table 'questions' you might need to download a tool like Microsoft Workbench or Sequel Ace
4. Once you connect to your mysql server you can create a database and then create a table by execting SQL Query

Now, when you run your application you should





## Virtual set up:

Installing Jenkins:

sudo yum -y update
sudo yum remove java* -y
sudo yum install -y java-17-amazon-corretto
sudo yum install git -y
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y

sudo service jenkins start
sudo chkconfig jenkins on

sudo cat /var/lib/jenkins/secrets/initialAdminPassword



Installing Docker:

sudo yum -y install docker
sudo systemctl start docker
sudo docker info

Also, to not have to type sudo before docker commands every time, you can add your user docker to the group by:
sudo gpasswd -a ec2-user docker
Make sure you restart your ssh connection after that or try this command:
sudo systemctl restart docker
