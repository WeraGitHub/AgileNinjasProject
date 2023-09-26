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


## Cloud set up:

### We can use our terraform files to create our infrastructure, including EC2 instance dedicated to running our CI/CD pipeline

1. Install terraform locally

    For linux:
    ```
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum -y install terraform
    ```
    For Mac:
    
    `brew install terraform`
    
    For Windows:
    
    `choco install terraform`
    
    Verify you have installed it successfully by running `terraform version` command.

2. Fork and then clone this repo and cd into it and then into infra folder:
    ```
    git clone https://github.com/WeraGitHub/AgileNinjasProject.git
    cd AgileNinjasProject/infra
    ```

3. Create a local filewithin the infra folder called *terraform.tfvars* where you enter your credentials:
   
    <img src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/0a16e55f-d6d9-441d-948c-d8029b4c5ec7" width="200" height="auto">
   
4. In your terminal confirm you are within the infra folder and initiate, validate (just in case), plan and apply terraform configuration, enter *yes* when prompted.
    
    `terraform innit`
    
    `terraform validate`
    
    `terraform plan`
    
    `terraform apply`
    
    Now you have fully funtional and nicely architected infrastructure, copy the load balancer link from your terminal and paste it into your browser! The application is up and running now! 🤩


## CI/CD set up:

1. To set up our Jenkins Pipeline we need to connet to our *pipeline-instance* in AWS Console. Log in and navigate to you EC2 instances, select our pipeline-instance and connect to it using Connect button.

   <img src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/29347eab-8dfe-4c9d-bd9f-6f7f3d2122b8" width="550" height="auto">

   <img src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/abdfb2aa-7b68-4bb3-a249-8181e0c425a0" width="550" height="auto">

3. In this aws provided terminal use the command below to get the Jenkins password

   `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

    
4. In another browser tab navigate to http://[Public Ip of the pipeline-instance]:8080 . This will open Jenkins and prompt you to enter the password (see step 2.).

5. Install all the suggested plugins and enter details for your Jenkins user.

6. While the Jenkins is updating we can set up github webhook, so when we make changes to our repo that will trigger Jenkins job automatically.

https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/69d11500-b3c8-493b-a864-d55f0bab860b



6. Next, install 4 more pluggings (from the Available plugins list): 

    <img src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/89b16e65-72c9-4587-b457-fd5fc0723594" width="600" height="auto">

7. Add your global credentials for DockerHub and AWS:

    <img src="https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/ed5da949-dabc-46b9-ae9a-45a05284c6ff" width="600" height="auto">


8. Now you are ready to create a new scripted pipeline job:

    ![image](https://github.com/WeraGitHub/AgileNinjasProject/assets/67145460/4c98ff74-710d-46a1-85a1-acbf23e2fb54)

    Run it and it all should all ok! 

### Hurraayy! CI/CD pipeline is now set up and waiting for any changes to your main branch. 🤯
