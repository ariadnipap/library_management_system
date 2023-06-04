# library_management_system
USER MANUAL
Library Management System application
This paper is a user manual for an application that was designed and developed for the semester project of Databases course at National Technical University of Athens. Our project is about a Library Management System, where schools can register with their respective library operators and add books to the database. School members can later register and reserve, borrow and review books in their school’s library through our system.
CONTENTS
A)	Installation of required python packages
B)	Downloading and connecting the database
C)	User interface instructions
Administrator
Library operators	
School members	


Developpers:
Panou Konstantina, el20144
Papanikolaou Ariadni, el20097
Tsouknida Vasiliki, el20042
National Technical University of Athens


A)	Installation of required python packages:
For the implementation of the backend part of our web application, we have used two python3 libraries, “flask” for the server-side and “flask-mysqldb” for the connection of the database with python. To install them on Windows, and to create the environment needed, please follow the instructions below:
-	Open WSL as Administrator
-	Run the commands:
mkdir Library_Management_System
cd Library_Management_System
py -3 -m venv Library_Management_System

-	Now the environment is created, and it needs to be activated, before installing Flask:
Scripts/activate
pip install Flask
pip install flask_mysqldb

-	And now, after downloading all the necessary files from the ( -- github repo --) and saving them in the environment “Library_Management_System” you just created, you are ready to run the app by running the commands:
setx FLASK_APP “app.py”
flask run

If everything is installed correctly, follow the address highlighted (it may differ on your computer) on a brower:
 

There is a case your WSL has “Restricted Execution Policy” so you will not be able to run the above command. Then, you should run this command before the “\Scripts\activate”
-	Set-ExecutionPolicy RemoteSigned
-	pip install Flask
A necessary condition for flask to connect correctly to the database is to correctly define the address and the port on which the database is running, the username, the password and the name of the database in the first lines of the app.py file. For example, based on what was mentioned in the previous sections, the correct configuration would be:

app.config['MYSQL_HOST'] = '172.18.0.2' 
app.config["MYSQL_USER"] = "root" 
app.config["MYSQL_PASSWORD"] = "examplepass" 
app.config["MYSQL_DB"] = "library_management_system"

On a system running windows and Mariadb is installed via XAMPP, then the desired configuration is:

app.config['MYSQL_HOST'] = 'localhost' 
app.config["MYSQL_USER"] = "root" 
app.config["MYSQL_PASSWORD"] = "" 
app.config["MYSQL_DB"] = "Library_Management_System"

See here for more information on execution policies in WSL:
https://learn.microsoft.com/el-gr/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.3

B)	Downloading and connecting the database:

1.	Start XAMPP: Launch the XAMPP control panel as administrator and start the Apache and MySQL services.
2.	Open phpMyAdmin: Open your web browser and enter "http://localhost/phpmyadmin" in the address bar. This will open the phpMyAdmin interface.
3.	Log in: If prompted, enter your MySQL username and password. By default, the username is "root" and the password is empty (blank). Click on the "Go" button to log in.
4.	Create a new database: In the phpMyAdmin interface, you will see a list of databases on the left-hand side. To create a new database, click on the "New" button. Enter a name for your database in the "Database name" field and choose the desired collation (usually "utf8_general_ci" is a good choice). Click on the "Create" button to create the database with the name library_management_system.
5.	Database created: Once you have created the database, you will see its name listed on the left-hand side of the phpMyAdmin interface.
6.	Click on your database and then click import on top of the page. Click on “Choose files” and choose the ddl from your computer called library_management_system_schema.sql. Do not edit the default options and click Go.
7.	Follow the same steps to upload the data by choosing the file library_management_system_data.sql.
8.	You have successfully uploaded the database. If everything goes well, by opening the address 127.0.0.1:5000 in the browser you will see the home page of our application.

C)	User interface instructions 

After the registration of a school in the database, the school’s library operator and school members can register. Books can be added to the system and get reserved, loaned and reviewed. Our application supports the following users:

•	One administrator that has control over the system
•	One library operator for every school registered in the system
•	School members divided into teachers and students

Once a user visits our homepage, he has 2 options: register to or log in the application. In his first visit, he needs to register to the system and fill in his information in the form. The users can register to the application by choosing their position from the drop-down list as well as their school.

Administrator
In our database, there is only one administrator registered under the username “admin”. It is obligatory for the administrator to register before every other user in the base. From then, he has to log in the database using the username “admin” and his password. Once he logs in the application, he is directed to the administrator’s homepage. From there, he can do the following actions:

	Schools:
•	Add a school to the database: once the administrator adds a school to the database, the schools don’t yet have a library operator. 
•	View the schools registered in the database, edit and delete a specific school (apart from its name). It is important to note that, when a school is deleted, all the school members of that school are deleted, including the library operator, as well as all its books, reservations and reviews.

Library operators:
•	View all the library operators and approve, delete or disable them: Following a school’s registration, a library operator is then registered to the system under that school name. Until after his approval, school members cannot register under that school name. It is important to note that, it is the obligation of the administrator to make sure that there is one and only approved library operator in a school. In case he chooses to disable or delete a library operator, the school members of the school he belongs to will not be able to log in the application. When he wants to change the library operator of that specific school, he needs to first delete the old library operator and then approve a library operator from the list of library operators right after.

Backup:
•	Create a copy of the entire database in his computer.
•	Restore the database from a copy he has created.

Queries:
The administrator is also able to execute multiple queries directly from his homepage by pressing the relevant buttons:

4.1.1. 	View a list with the total number of loans per school (Search criteria: year, calendar month, e.g. January)
4.1.2. For a given book category (user-selected), show which authors belong to it and which teachers have borrowed books from that category in the last year.
4.1.3. Find young teachers (age < 40 years) who have borrowed the most books and the number of books. 
4.1.4. Find authors whose books have not been borrowed. 
4.1.5. Find which operators have loaned the same number of books in a year with more than 20 loans.
4.1.6. Many books cover more than one category. Among field pairs (e.g., history and poetry) that are common in books, find the top-3 pairs that appeared in borrowings. 4.1.7. Find all authors who have written at least 5 books less than the author with the most books.

Profile:
•	View his information and edit it by clicking on the “Edit” button. The updated information is saved in the database after he presses “Save”.
•	Change his password by clicking on the “Change password" button. He needs to add his current and new password and press “Save” to commit the password change.
Log out of the system from the Log out button of the homepage
Library operators
In our application, there can only be one approved library operator registered in the system under a specific school. Until the approval of one of the pending library operators of the school by the administrator, many library operators can register in the application under the school name, but this is forbidden after the approval of one of them. The library operators that are not yet approved cannot log in the application. Also, students and teachers cannot use the application until an operator gets approved in their school. Once the approved library operator is logged in the database, he is directed to the library operator homepage. From there he can do the following actions:

Users
•	View all the school members of his school and approve or reject the pending registration requests or delete/disable them. He also has access to a drop-down list with all the usernames registered under his school.
•	Once he approves a registration request, he can click on the “Info” button to view the school member’s information and print his Library ID card.

Books
•	Add books to his school’s online library through the relevant form.
•	View all the books he has registered in the database with their respective titles and search them by title/ category/ author/ copies (4.2.1.). By clicking on a book title, he is redirected to a page, where all the books registered under the title are displayed, as well as their full description. Through that form, he can edit the information about a specific book ID, which will later be displayed with its updated information in the initial page. He can also delete a book ID (delete a physical copy of a book under the ID he is deleting), but only if there are not pending reservations or active loans under that ID.

Reviews
•	View all reviews made by the members of his school and delete any review he considers necessary to.
•	Approve or reject any pending reviews made from students. It is important to note that teachers’ reviews are directly submitted, whereas students’ reviews need to be approved first.
•	4.2.3. View the average Ratings per borrower and category (Search criteria: user/category)

Reservations
•	See all the reservations made by school members and approve any pending ones. In case the library operator tries to approve a reservation about an unavailable book ID, he will receive an error. He will also receive an error in case he tries to accept a reservation made by a user who has already exceeded the number of books he is allowed to loan this week or if he has not returned a book on time. The library operator cannot reject pending reservations and cannot set the reservations and loans limit manually.

Loans
•	Record a loan directly, without a reservation by entering a book ID and the member’s username, thus skipping the reservation. It is important to note that these loans still follow the rules of the library: if the operator tries to record a loan about a book ID that is currently reserved or loaned, he will receive an error message. An error message will also occur when he tries to loan a book to a member that has exceeded the maximum number of loans or reservations allowed in the current week. Finally, he will receive an error if the member already has the book in his possession or there is a pending reservation of this book under his name or in the case that he enters an invalid book ID, invalid username or a username of a member that belongs to a different school.
•	View all the loans made by users and record the return of a book upon its physical return by the member.
•	View a record of all the delayed returns (as well as the ones that have already been returned).
•	4.2.2. Find all borrowers who own at least one book and have delayed its return. (Search criteria: First Name, Last Name, Delay Days).
Profile
•	View his information and edit it by clicking on the “Edit” button. The updated information is saved in the database after he presses “Save”. The library operator cannot change his username, the school he is registered to or his position.
•	Change his password by clicking on the “Change password" button. He needs to add his current and new password and press “Save” to commit the password change.
Log out of the system from the Log out button of the homepage

School members (Teachers & Students)

School members can register in the system from the application’s homepage. They can choose their school from a drop-down list of schools and fill in the rest of their information through the form. In case they have registered too early and there is not yet an approved library operator registered in their school, their registration is denied. After registering, they will receive a message for a successful reservation and wait for an approval from the library operator of their school. While waiting for that approval, they cannot log in the application. Once the approval is granted and the school member is logged in the database, he is directed to the user’s homepage. From there, he has access to the following actions:

Books
•	View all the books registered in his school’s system and search by Title, Author or Category. By pressing on a book title, he is redirected to a page where all the books registered under the title he clicked on are displayed as well as their full description.  
•	From there, he can click on “Make reservation” in order to reserve that specific book registered under its ID. The book’s status is displayed next to its ID. Students can borrow up to 2 books per week and also reserve up to 2 books. Teachers can only borrow 1 book per week and reserve 1 more. If the reservation is successful (which means the user meets the loan criteria), he is redirected to a page stating that the reservation is successful and is waiting for an approval by the library operator. In case the user doesn’t meet the loan criteria: he has exceeded the number of reserved and borrowed books this week, he has an active delayed book return, he already has the book reserved or he already has the book in his possession, he is redirected to a page that states that the reservation was unsuccessful.
•	In that specific page, he can also click on “See reviews” to display all the reviews made by other members of his school under the title he is interested in.

Reviews
•	View all the reviews he has submitted for a book title and their details and status. Students need approval from the library operator in order to share a review, whereas teachers can directly submit reviews about titles.
•	Submit a new review about any book title in his school’s system. Students need approval from the library operator in order to publish a review, whereas teachers can directly submit reviews about titles. For the review to be submitted, the rating need to be between the values 0 and 5 and the title needs to be a valid book title registered in his school’s system.
Reservations
•	Manage his reservations and check their status: in order for a reservation to lead to a loan, the library operator needs to approve it. A user can cancel his reservation at any time, while pending reservations that have not yet been approved are automatically expired after 1 week.
Loans
•	4.3.2. List of all books borrowed by this user: information about all the loans the user has made and their status, where the active ones are displayed on top with their respective due dates.
Profile
•	View his information. A teacher can edit it by clicking on the “Edit” button. The updated information is saved in the database after he presses “Save”. A teacher cannot change the school he is registered to, his username or his position.
•	Change his password by clicking on the “Change password" button. He needs to add his current and new password and press “Save” to commit the password change.
Log out of the system from the Log out button of the homepage
Lastly, whenever a school members want his account deactivated or deleted, he needs to get in contact with the library operator of his school.

