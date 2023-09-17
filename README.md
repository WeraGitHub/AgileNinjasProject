# AgileNinjasProject
<img width="1506" alt="image" src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/9242a88a-e931-4d7d-a1b4-f3f77678396b">


## Getting Started locally

1. Clone the repository:
`git clone https://github.com/WeraGitHub/AgileNinjasProject.git`

2. Navigate to the project directory:
`cd AgileNinjasProject`

3. Install the required packages:
`pip install -r requirements.txt`

    use pip3 on Mac: `pip3 install -r requirements.txt` 

4. Start the application:
`python app.py` or `python3 app.py`

   Alternatively you can manually navigate to the app.py file in your IDE and run it from here.

5. Open your web browser and go to http://localhost:5000.


For this application to work properly, you need to connect to a mysql database with table called 'questions'. Best option is to run a mysql container in docker.

6. Make sure you have Docker Desktop on your computer
  
7. Run this command in your terminal `docker run -d -p 3306:3306 --name mysql-db -e MYSQL_ROOT_PASSWORD=password mysql:latest`

8. To create a 'mydatabase' with table 'questions' you might need to download a tool like Microsoft Workbench or Sequel Ace

9. Connect to it using details from the app:
   
   <img src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/706feb1b-81f4-4a8f-bc83-cc5c1fa11366" width="400" height="auto">

10. Once you connect to your mysql server you can create a database and then create a table by execting SQL Query, finished product should look like this:

    <img src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/d6e78830-1a55-4a66-a298-548de1888a7a" width="500" height="auto">

#### Now, when you run your application you should have everything working correctly.

<br /><br /><br />


## Virtual set up:

### We need one EC2 instance with Jenkins and Docker installed
Make sure you have ports 22 and 8080 open.

<img src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/4cdeda46-28c9-434e-b1d3-79019ff045af" width="600" height="auto">

#### Create your EC instance and connect to it via ssh.


#### Docker:
Installing Docker:
```
sudo yum -y install docker
sudo systemctl start docker
sudo docker info
```
Also, to not have to type sudo before docker commands every time, you can add your user docker to the group by:

`sudo gpasswd -a ec2-user docker`

Make sure you restart your ssh connection after that or try this command:

`sudo systemctl restart docker`


#### Webhook
http://[ip-of-your-ec2-instance]:8080/github-webhook/



https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/749834f7-8b46-4c39-902c-37cdcc70e1c9



#### Jenkins:
Installing Jenkins:
```
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
```

Open your browser and navigate to http://[ip-of-your-ec2-instance]:8080 . 

Enter the long password - see the last command in the console.

Install suggested pluggins. 

Next, install 4 more pluggings (from the Available plugins list): 

<img src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/89b16e65-72c9-4587-b457-fd5fc0723594" width="600" height="auto">

And add your global credentials for DockerHub and AWS:

<img src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/ed5da949-dabc-46b9-ae9a-45a05284c6ff" width="600" height="auto">


####



# TODO: Jenkins pipeline job screenshot + all the infrastructure

