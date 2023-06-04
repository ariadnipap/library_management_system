from flask import Flask, render_template, request, redirect, session, flash, url_for, get_flashed_messages
from flask_mysqldb import MySQL
import base64
import time 
import pipes
import os
import subprocess

app = Flask(__name__, static_folder='static')
app.secret_key = 'arikonvas'

# Connecting our Flask app to our MySQL Database
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'Library_Management_System'

mysql = MySQL(app)


# The main page
@app.route("/")
def main():

    return render_template('main.html')
 

# The users's home page, a different template for each users type
#but the same route
@app.route("/homepage")
def homepage():

    if 'username' in session:

        # Get the user's position from the session
        position = session.get('position')
        username = session['username']

        success = get_flashed_messages(category_filter=['backup_success'])

        if position == 'student':
            
            return render_template('user_homepage.html', username=username)
        
        elif position == 'teacher':

            return render_template('user_homepage.html', username=username)
        
        elif position == 'library_operator':

            return render_template('library_operator_homepage.html', username=username)
        
        elif position == 'admin':

            return render_template('admin_homepage.html', username=username, success=success)
        else:
            return redirect('/')
    
    else:
        return redirect('/login_form')
    

#The register form, with all the already registered schools
@app.route('/register_form')
def register_form():
    
    cursor = mysql.connection.cursor()
    query = "SELECT school_name FROM school"
    cursor.execute(query)
    schools = [row[0] for row in cursor.fetchall()]
    cursor.close()
    
    # Get the error message from the query parameters
    error = get_flashed_messages(category_filter=['registration_error'])
    success = get_flashed_messages(category_filter=['registration_success'])
    
    return render_template('register_form.html', schools=schools, error=error, success=success)
    

# The registration process
@app.route('/register', methods = ['POST', 'GET'])
def register():
    if request.method == 'GET':
        return redirect(url_for('register_form'))
        
        
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        date_of_birth = request.form['date_of_birth']
        email = request.form['email']
        school = request.form['schools']
        position = request.form['position']
        phone_number = request.form['phone_number']
        cursor = mysql.connection.cursor()
        cursor.callproc('check_username', [username])
        result = cursor.fetchall()
        user_exists = result[0][0]
        cursor.close()
        cursor = mysql.connection.cursor()

        if user_exists:
            error = 'Username already used!'
            flash(error, 'registration_error')
            return redirect(url_for('register_form'))


        # Get the library operator for the school
        cursor.execute(
            "SELECT library_operator_username FROM school_member "
            "INNER JOIN library_operator "
            "ON school_member.school_member_username = library_operator.library_operator_username "
            "WHERE school_member.school_name = %s "
            "AND library_operator.approved = 1",
            (school,)
        )
        result = cursor.fetchall()

        if result:
            library_operator_username = result[0]

            if position == 'Library_Operator':
                error = school + ' already has an approved library operator!'
                flash(error, 'registration_error')
                return redirect(url_for('register_form'))


            if position == 'Teacher':
                # Insert into school_member and teacherstudent tables for a teacher
                cursor.execute(
                    "INSERT INTO user (username, password, first_name, last_name, date_of_birth, email, phone_number) VALUES (%s, %s, %s, %s,%s, %s, %s)",
                    (username, password, first_name, last_name, date_of_birth, email, phone_number)
                )
                cursor.execute(
                    "INSERT INTO school_member (school_member_username, school_name) VALUES (%s, %s)",
                    (username, school)
                )
                cursor.execute(
                    "INSERT INTO teacherstudent (username, position, num_of_books_allowed, library_operator_username, approved) "
                    "VALUES (%s, %s, %s, %s, %s)",
                    (username, 'teacher', 1, library_operator_username, 0)
                )
                mysql.connection.commit()

                success = 'You have been registered! Approval pending.'
                flash(success, 'registration_success')
                return redirect(url_for('register_form'))
            

            if position == 'Student':
                # Insert into school_member and teacherstudent tables for a student
                cursor.execute(
                    "INSERT INTO user (username, password, first_name, last_name, date_of_birth, email,phone_number) VALUES (%s, %s, %s, %s,%s, %s, %s)",
                    (username, password, first_name, last_name, date_of_birth, email, phone_number)
                )
                cursor.execute(
                "INSERT INTO school_member (school_member_username, school_name) VALUES (%s, %s)",
                (username, school)
                )
                cursor.execute(
                "INSERT INTO teacherstudent (username, position, num_of_books_allowed, library_operator_username, approved) "
                "VALUES (%s, %s, %s, %s, %s)",
                (username, 'student', 2, library_operator_username, 0)
                )
                mysql.connection.commit()

                success = 'You have been registered! Approval pending.'
                flash(success, 'registration_success')
                return redirect(url_for('register_form'))
            
            
        else:   
            if position == 'Library_Operator':
                # Insert into school_member and library_operator tables
                cursor.execute(
                    "INSERT INTO user (username, password, first_name, last_name, date_of_birth, email, phone_number) VALUES (%s, %s, %s, %s,%s, %s, %s)",
                    (username, password, first_name, last_name, date_of_birth, email, phone_number))
                cursor.execute(
                    "INSERT INTO school_member (school_member_username, school_name) VALUES (%s, %s)",
                    (username, school)
                    )
                cursor.execute(
                    "INSERT INTO library_operator (library_operator_username, administrator_username, approved) "
                    "VALUES (%s, %s, %s)",
                    (username, 'admin', 0)
                    )
                mysql.connection.commit()

                success = 'You have been registered! Approval pending.'
                flash(success, 'registration_success')
                return redirect(url_for('register_form'))

    cursor.close()

    error = 'You are not able to register yet. Please contact your school.'
    flash(error, 'registration_error')
    return redirect(url_for('register_form'))


# A function used during the login process
def validate_user(username, password):
    cur = mysql.connection.cursor()

    try:
        # Execute the login_user query to validate the user
        cur.callproc('login_user', (username, password))
        result = cur.fetchone()

        if result:
            message = result[0]

            if message == 'Admin login successful.':
                return 'admin'
            elif message == 'Library operator login successful.':
                return 'library_operator'
            elif message == 'Wrong password.':
                return 'wrong_password'
            elif message == 'You are not registered in the system.':
                return 'not_registered'
            elif message == 'You are not an approved school member yet.':
                return 'not_approved'
            elif message == 'Teacher login successful.':
                return 'teacher_login'
            elif message == 'Student login successful.':
                return 'student_login'
            elif message == 'Your school does not have an approved library operator.':
                return 'not_approved_library_operator'
            
        return 'unknown_error'  # If the procedure does not return any recognized message
    finally:
        cur.close()


# The login process
@app.route('/login_form', methods=['GET', 'POST'])
def login_form():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        # Validate the user credentials against our database using the function above
        validation_result = validate_user(username, password)

        # Store the user's information in the session
        # Keeping the position for the whole session to enable functionalities
        if validation_result == 'teacher_login':

            session['username'] = username
            session['position'] = 'teacher'
           
            # Redirect the user to the homepage
            return redirect('/homepage')
        
        if validation_result == 'student_login':
           
            session['username'] = username
            session['position'] = 'student'
            
            # Redirect the user to the homepage
            return redirect('/homepage')
    
        elif validation_result == 'admin':
           
            session['username'] = username
            session['position'] = 'admin'

            # Redirect the user to the homepage
            return redirect('/homepage')

        elif validation_result == 'library_operator': 
           
            session['username'] = username
            session['position'] = 'library_operator'

            # Redirect the user to the homepage
            return redirect('/homepage')
        
        elif validation_result == 'wrong_password':
            error = 'Wrong password'
        elif validation_result == 'not_registered':
            error = 'You are not registered in the system'
        elif validation_result == 'not_approved':
            error = 'You are not an approved school member yet'
        elif validation_result == 'not_approved_library_operator':
            error = 'Your school does not have an approved library operator.'
        else:
            error = 'Unknown error occurred'
            redirect('/')

        # Render the login page with the error message
        return render_template('loginform.html', error=error)

    return render_template('loginform.html')


# Every teacher/student can see their personal information through this route
@app.route('/user_information', methods=['GET'])
def user_information():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')
    
    username = session['username']

    cursor = mysql.connection.cursor()
    cursor.callproc('view_user_information', [username])
    result = cursor.fetchall()

    cursor.close()

    if len(result) == 0:
        return 'User not found.'

    return render_template('view_user_information.html', user=result[0])


# Students are not able to change their personal information while all the other
# type of users are able to, through this route.
@app.route('/update_teacher_information', methods=['GET', 'POST'])
def update_teacher_information():
    # Get the user's position from the session
    position = session.get('position')

    if position == 'teacher' or position == 'library_operator' or position == 'admin':
        if request.method == 'GET':
            username = session['username']

            cursor = mysql.connection.cursor()
            cursor.callproc('view_user_information', [username])
            result = cursor.fetchall()
            cursor.close()

            if len(result) == 0:
                return 'User not found.'
        
        else:
            # Retrieve the form data
            first_name = request.form['first_name']
            last_name = request.form['last_name']
            date_of_birth = request.form['date_of_birth']
            email = request.form['email']
            phone_number = request.form['phone_number']

            # Update the user's information in the database
            username = session['username']
            cursor = mysql.connection.cursor()
            cursor.callproc('update_teacher_information', [username, first_name, last_name, date_of_birth, email, phone_number])
            cursor.close()
            mysql.connection.commit()

            cursor = mysql.connection.cursor()
            cursor.callproc('view_user_information', [username])
            result = cursor.fetchall()
            cursor.close()

            return redirect('/user_information')

        
        # Redirect to the edit_user_information page for teachers
        return render_template('update_teacher_information.html', user = result[0])
    elif position == 'student':
        # Set a flash message indicating lack of authorization
        flash('You are not authorized to change your personal information', 'user_info_error')
        # Redirect to the view_user_information page
        return redirect('/user_information')
    else:
        return redirect('/')


# Every user can change their password
@app.route('/change_password', methods=['GET', 'POST'])
def change_password():
    if request.method == 'POST':
        p_username = session['username']
        p_current_password = request.form['current_password']
        p_new_password = request.form['new_password']

        conn = mysql.connection
        cursor = conn.cursor()

        error = None  # Initialize the error variable
        success = None  # Initialize the success variable

        try:
            # Call the SQL procedure
            cursor.callproc('change_user_password', (p_username, p_current_password, p_new_password))
            result = cursor.fetchone()

            if result:
                message = result[0]
                if message == 'Password changed successfully.':
                    success = 'Password changed!'
                elif message == 'Current password is incorrect.':
                    error = 'Current password is incorrect!'
                else:
                    error = 'Unknown error occurred'
            else:
                error = 'Unknown error occurred'

            cursor.close()
            conn.commit()

        except Exception as e:
            print(f"Error: {e}")
            error = 'Unknown error occurred'

        # Render the login page with the error message
        return render_template('change_password.html',username = p_username, error=error, success=success)

    return render_template('change_password.html')


# The library operator can add books to their school's library
@app.route('/book_insertion', methods = ['POST', 'GET'])
def book_insertion():
    if request.method == 'GET':
        return render_template('book_insertion.html')
        
    if request.method == 'POST':
     isbn = request.form['ISBN']
     title = request.form['title']
     author_names = request.form['author_name']
     category_names = request.form['category']
     pages_number = request.form['pages_number']
     publisher = request.form['publisher']
     summary = request.form['summary']
     copies = request.form['copies']
     language = request.form['language']
     keyword_names = request.form['keyword']
     cover=request.files['image']
     cover_data=cover.read()
     encoded_cover = base64.b64encode(cover_data).decode('utf-8')
     library_operator_username = session['username']
     cursor = mysql.connection.cursor()
     args=(isbn, title, pages_number, publisher, summary, copies, encoded_cover, library_operator_username, language, author_names, category_names, keyword_names)
     cursor.callproc('add_book', args=args)
     mysql.connection.commit()
     cursor.close()
     
    success = 'Done! Now book is in your library!'
    return render_template('book_insertion.html', success=success)
   

# The admin can add schools to the library management system
@app.route('/register_school', methods = ['POST', 'GET'])
def register_school():

    # Initializing the variables
    success = None
    error = None

    if request.method == 'GET':
        return render_template('register_school.html')
        
    if request.method == 'POST':
     school_name = request.form['school_name']
     city = request.form['city']
     email = request.form['email']
     school_director_first_name = request.form['school_director_first_name']
     school_director_last_name = request.form['school_director_last_name']
     street_number = request.form['street_number']
     street_name = request.form['street_name']
     zip_code = request.form['zip_code']
     phone_number = request.form['phone_number']
     cursor = mysql.connection.cursor()
     args=(school_name, city, email, school_director_first_name, school_director_last_name, street_number, street_name, zip_code, phone_number)
     cursor.callproc('register_school', args=args)
     result = cursor.fetchone()
     cursor.close()
     mysql.connection.commit()
     
   
    if result:
        message = result[0]
        if message == 'Done!! Now school is in the base!':
            success = 'Done!! Now school is in the base!'
        elif message == 'School already exists.':
            error = 'School already exists.'
        else:
            error = 'Unknown error occurred'
   
    return render_template('register_school.html', success=success, error=error)
    

# The admin can see all the schools, delete a school and all of it's data,
# and can also change the school's information
@app.route('/view_schools', methods=['GET', 'POST'])
def schools():
    if 'position' not in session or session['position'] != 'admin':
        return "You are not authorized to view schools."
    
    if request.method == 'GET':

        cur = mysql.connection.cursor()
        cur.execute("SELECT school_name, city, email, school_director_first_name, school_director_last_name, library_operator_first_name, library_operator_last_name, street_number, street_name, zip_code, school_phone_number FROM school")
        result = cur.fetchall()
        cur.close()

        school_names = []
        cities = []
        emails = []
        school_director_first_names = []
        school_director_last_names = []
        library_operator_first_names = []
        library_operator_last_names = []
        street_numbers = []
        street_names = []
        zip_codes = []
        phone_numbers = []

        for row in result:
            school_names.append(row[0])
            cities.append(row[1])
            emails.append(row[2])
            school_director_first_names.append(row[3])
            school_director_last_names.append(row[4])
            library_operator_first_names.append(row[5])
            library_operator_last_names.append(row[6])
            street_numbers.append(row[7])
            street_names.append(row[8])
            zip_codes.append(row[9])
            phone_numbers.append(row[10])

        return render_template('view_schools.html', school_names=school_names, cities=cities, emails=emails, school_director_first_names=school_director_first_names, school_director_last_names=school_director_last_names, library_operator_first_names=library_operator_first_names, library_operator_last_names=library_operator_last_names, street_numbers=street_numbers, street_names=street_names, zip_codes=zip_codes, phone_numbers=phone_numbers)


# Route for deleting a school
@app.route('/delete_school/<string:school_name>', methods=['GET', 'POST'])
def delete_school(school_name):
    cur = mysql.connection.cursor()

    cur.execute("DELETE FROM review WHERE user_username IN ( SELECT school_member_username FROM school_member WHERE school_name = %s )", (school_name,))
    cur.execute("DELETE FROM user WHERE username IN ( SELECT school_member_username FROM school_member WHERE school_name = %s )", (school_name,))
    cur.execute("DELETE FROM school WHERE school_name = %s", (school_name,))
    mysql.connection.commit()
    cur.close()
    return redirect('/view_schools')


# Route for editing the school's information
@app.route('/edit_school', methods=['GET', 'POST'])
def edit_school():

    if 'position' not in session or session['position'] != 'admin':
        return "You are not authorized to edit schools."
    
    if request.method == 'GET':
        school_name = request.args.get('school_name')
        cur = mysql.connection.cursor()
        cur.execute('SELECT school_phone_number, email, school_director_first_name, school_director_last_name, city, zip_code, street_name, street_number FROM school WHERE school_name = %s', (school_name,))
        school_data = cur.fetchone()
        cur.close()

        if school_data:
            return render_template('edit_school.html', school_name=school_name, school_data=school_data)
        else:
            return "School not found."
    

    elif request.method == 'POST':

        school_name = request.form['school_name']
        city = request.form['city']
        email = request.form['email']
        school_director_first_name = request.form['school_director_first_name']
        school_director_last_name = request.form['school_director_last_name']
        street_number = request.form['street_number']
        street_name = request.form['street_name']
        zip_code = request.form['zip_code']
        school_phone_number = request.form['school_phone_number']
        
        # Update the school in the database
        try:
            cur = mysql.connection.cursor()
            # Update the other columns leaving school_name unchanged
            cur.execute("UPDATE school SET city = %s, email = %s, school_director_first_name = %s, school_director_last_name = %s, street_number = %s, street_name = %s, zip_code = %s, school_phone_number = %s WHERE school_name = %s",
                        (city, email, school_director_first_name, school_director_last_name, street_number, street_name, zip_code, school_phone_number, school_name))
            mysql.connection.commit()
            cur.close()

            success =  "School updated successfully."
            cur = mysql.connection.cursor()
            cur.execute('SELECT school_phone_number, email, school_director_first_name, school_director_last_name, city, zip_code, street_name, street_number FROM school WHERE school_name = %s', (school_name,))
            school_data = cur.fetchone()
            cur.close()
            return render_template("edit_school.html", school_name=school_name, school_data=school_data, success=success)

        except Exception as e:
            print(f"Error updating school: {str(e)}")

    return render_template('edit_school.html')


# This is query 3.2.1 for the teacher/students
@app.route('/book_search', methods=['GET', 'POST'])    
def book_search():
    if request.method == 'POST':
        title_query = request.form.get('title_query')
        category_query = request.form.get('category_query')
        author_query = request.form.get('author_query')
        username = session['username']
        cursor = mysql.connection.cursor()

        # Get the school name for the user
        cursor.execute('SELECT school_name FROM school_member WHERE school_member_username = %s', (username,))
        result = cursor.fetchone()
        if result:
            school_name = result[0]
        else:
            # Handle the case where no school name is found
            school_name = None  

        # Construct the query conditions based on the search criteria
        conditions = []
        params = []
        if title_query:
            conditions.append('title LIKE %s')
            params.append(f'%{title_query}%')
        if category_query:
        # Add the condition to the list only if the category exists
            conditions.append('book_id IN (SELECT book_id FROM book_category WHERE category LIKE %s)')
            params.append(f'%{category_query}%')
        if author_query:
            conditions.append('book_id IN (SELECT book_id FROM book_author WHERE author_name LIKE %s)')
            params.append(f'%{author_query}%')
        
        # Build the SQL query
        query = 'SELECT DISTINCT title FROM book WHERE school_name = %s'
        if conditions:
            query += ' AND ' + ' AND '.join(conditions)
            params.insert(0, school_name)
        else:
            params = (school_name,)
        
        # Perform the book search based on the search criteria and school name
        cursor.execute(query, params)
        result = cursor.fetchall()
        books = []
        if len(result) == 0:
                return render_template('book_search.html', books=[])
        for row in result:
            if len(row) > 0:
                book_title = row[0]
                book = {
                    'title': book_title,
                }
                books.append(book)
    

        # Close the database connection
        cursor.close()

        return render_template('book_search.html', books=books)

    
    if request.method == 'GET':
        username = session['username']
        cursor = mysql.connection.cursor()
        cursor.callproc('view_book_titles_teacherstudent', (username,))
        result = cursor.fetchall()
        if len(result) == 0:
                return 'User not found.'
        books = []
        for row in result:
            if len(row) > 0:
                book_title = row[0]
                book = {
                    'title': book_title,
                }
                books.append(book)
    

        # Close the database connection
        cursor.close()
        
        return render_template('book_search.html', books=books)
    
    return render_template('book_search.html', books=[])


@app.route('/book_details')
def book_details():
    if 'username' not in session:
        return 'User not logged in.'

    username = session['username']
    title = request.args.get('title')

    cursor = mysql.connection.cursor()
    cursor.callproc('view_book_details_teacherstudent', (username,title))

    result = cursor.fetchall()

    cursor.close()

    if len(result) == 0:
        return 'PROBLEMMMMM.'
    books = []
    book_ids = []
    status_list = []

    for row in result:
        book_title = title
        if len(row) > 0:
            book_ISBN = row[0]
        if len(row) > 1:
            book_pages_number = row[1]
        if len(row) > 2:
            book_publisher = row[2]
        if len(row) > 3:
            book_summary = row[3]
        if len(row) > 4:
            book_language = row[4]

        book = {
            'ISBN': book_ISBN,
            'title': book_title,
            'pages_number': book_pages_number,
            'publisher': book_publisher,
            'summary': book_summary,
            'language': book_language
        }
        books.append(book)

        cursor = mysql.connection.cursor()
        query = "SELECT book_id FROM book WHERE ISBN = %s AND title = %s AND pages_number = %s AND publisher = %s AND summary = %s AND language = %s AND school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
        cursor.execute(query, (book_ISBN, book_title, book_pages_number, book_publisher, book_summary, book_language, username))
        result = cursor.fetchall()

        book_id_list = []
        status_sublist = []

        for row in result:
            book_id = row[0]
            book_id_list.append(book_id)

            query = "SELECT 1 FROM reserves WHERE book_id = %s AND returned_date IS NULL"
            cursor.execute(query, (book_id,))
            if cursor.rowcount > 0:
                status = 'Reserved'
                status_sublist.append(status)
            else:
                status = 'Available'
                status_sublist.append(status)

        book_ids.append(book_id_list)
        status_list.append(status_sublist)

        cursor.close()


    #Authors        
    cursor = mysql.connection.cursor()
    cursor.callproc('view_book_authors_teacherstudent', (username,title))
    result = cursor.fetchall()  
    cursor.close()
    book_authors= [row[0] for row in result]
    
    #Categories
    cursor = mysql.connection.cursor()
    cursor.callproc('view_book_categories_teacherstudent', (username,title))
    result = cursor.fetchall()  
    cursor.close()
    book_categories= [row[0] for row in result]
    
    #Keywords
    cursor = mysql.connection.cursor()
    cursor.callproc('view_book_keywords_teacherstudent', (username,title))
    result = cursor.fetchall()  
    cursor.close()
    book_keywords= [row[0] for row in result]
         

    return render_template('book_details.html', books=books, book_ids=book_ids, status_list=status_list, book_authors = book_authors, 
                           book_categories= book_categories, book_keywords = book_keywords,book_title=title)


# Teachers and students can make reservations on any book id, and we check internally if the user's reservation critiria are met
@app.route('/make_reservation')
def make_reservation():
    try:
        username = session['username']
        book_id = request.args.get('book_id')
        cursor = mysql.connection.cursor()
        # Execute the stored procedure
        cursor.callproc('make_reservation', (username, book_id))

        # Close the cursor
        cursor.close()
        mysql.connection.commit()

        return render_template('reservation_succeded.html')
    except mysql.connection.Error as error:
        # Handle any database errors
            error_message = error.args  # Get the error message as a tuple
            print(error_message)

        # Check for specific error messages
            if error_message == (1644, 'You have already reserved this book.'):
                message = 'You have already reserved this book.'
          
                return render_template('reservation_failed.html', message=message)
            elif error_message == (1644, 'You have not returned a book on time.'):
                message = 'You have not returned a book on time.'
           
                return render_template('reservation_failed.html', message=message)
            elif error_message == (1644, 'You already have this book in your possession'):
                message = 'You already have this book in your possession'
          
                return render_template('reservation_failed.html', message=message)
            elif error_message == (1644, 'You have exceeded the maximum number of reserved/borrowed books.'):
                message = 'You have exceeded the maximum number of reserved/borrowed books.'
            
                return render_template('reservation_failed.html', message=message)
            else:
                return 'Error: ' + str(error_message)


#Teacher or student can see the reviews of a specific book title
@app.route('/view_reviews_teacherstudent')
def view_reviews_teacherstudent():
    book_title = request.args.get('book_title')
    username = session['username']
    cursor = mysql.connection.cursor()
    cursor.callproc('view_reviews_per_title', (book_title, username))
    result = cursor.fetchall()
    text=[]
    likert_rating=[]
    user_username=[]
    for row in result:
        text.append(row[0])
        likert_rating.append(row[1])
        user_username.append(row[2])
    cursor.close()
    return render_template('view_reviews_teacherstudent.html', text=text, likert_rating=likert_rating, user_username=user_username, book_title= book_title)


# Teachers and students can add reviews on any title that exists in their school's library
@app.route('/add_review', methods=['GET', 'POST'])
def add_review():

    username = session['username']
    cursor = mysql.connection.cursor()
    query = "SELECT DISTINCT b.title FROM book b WHERE b.school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
    cursor.execute(query, (username,))
    titles = [row[0] for row in cursor.fetchall()]
    cursor.close()


    if request.method == 'POST':
        p_title = request.form['book_title']
        p_text = request.form['text']
        p_likert_rating = request.form['rating']
        p_user_username = session['username']

        conn = mysql.connection
        cursor = conn.cursor()

        error = None  # Initialize the error variable
        success = None  # Initialize the success variable
        try:
            # Call the SQL procedure
            cursor.callproc('add_review', (p_title, p_text, p_likert_rating, p_user_username))
            result = cursor.fetchone()

            if result:
                message = result[0]
                if message == 'Review added successfully.':
                    success = 'Review added successfully.'
                elif message == 'Review approval pending.':
                    success = 'Review approval pending.'
                elif message == 'This book title does not exist in the database.':
                    error = 'This book title does not exist in the database.'
                elif message == 'You are not approved to write reviews.':
                    error = 'You are not approved to write reviews.' 
                else:
                    error = 'Unknown error occurred.'
            else:
                error = 'Unknown error occurred.'

            cursor.close()
            conn.commit()


        except Exception as e:
            print(f"Error: {e}")
            error = 'Unknown error occurred.'

        # Render the add_review page with the error message
        return render_template('add_review.html', error=error, success=success, titles=titles)
    
    return render_template('add_review.html', titles=titles)


# Teachers and students can see his reviews and delete them 
@app.route('/view_my_reviews')
def view_my_reviews():
    username = session['username']
    cursor = mysql.connection.cursor()
    cursor.callproc('my_reviews', (username,))
    result = cursor.fetchall()
    title= []
    text=[]
    likert_rating=[]
    status=[]
    review_id=[]
    for row in result:
        title.append(row[0])
        likert_rating.append(row[1])
        text.append(row[2])
        review_id.append(row[3])
        status.append(row[4])
    cursor.close()
    return render_template('view_my_reviews.html', text=text, likert_rating=likert_rating, title=title, status=status, review_id=review_id)


#Teachers and students can delete their review
@app.route('/delete_my_review', methods=['POST'])
def delete_my_review():

    if 'username' not in session:
        return 'User not logged in.'

    username = session['username']
    review_id = request.form['review_id']
    
    # Call the delete_my_review procedure
    cursor = mysql.connection.cursor()
    cursor.callproc('delete_my_review', (username, review_id))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Display the result message
    if result[0] == 'Review deleted successfully.':
        success = 'Review deleted successfully.'
        flash(success, 'cancel_success')
        return redirect(url_for('view_my_reviews'))
    
    elif result[0] == 'Cannot delete review. Invalid review ID.':
        error = 'Cannot delete review.'
        flash(error, 'cancel_error')
        return redirect(url_for('view_my_reviews'))


# The library operator can see all reviews of their school, approve and delete them   
@app.route('/view_reviews_library_operator')
def view_reviews_library_operator():
    username = session['username']
    error = get_flashed_messages(category_filter=['delete_error'])
    success = get_flashed_messages(category_filter=['delete_success'])
    cursor = mysql.connection.cursor()
    cursor.callproc('view_reviews_library_operator', (username,))
    result = cursor.fetchall()
    user_username = []
    title= []
    text=[]
    likert_rating=[]
    status=[]
    review_id=[]
    for row in result:
        review_id.append(row[0])
        title.append(row[1])
        likert_rating.append(row[2])
        text.append(row[3])
        user_username.append(row[4])
        status.append(row[5])
    cursor.close()
    return render_template('view_reviews_library_operator.html', text=text, likert_rating=likert_rating, title=title, status=status, review_id=review_id, user_username=user_username, error = error, success = success)


@app.route('/delete_review', methods=['POST'])
def delete_review():

    if 'username' not in session:
        return 'User not logged in.'

    username = session['username']
    review_id = request.form['review_id']
    
    cursor = mysql.connection.cursor()
    cursor.callproc('delete_review', (username, review_id))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Display the result message
    if result[0] == 'Review deleted successfully.':
        success = 'Review deleted successfully.'
        flash(success, 'delete_success')
        return redirect(url_for('view_reviews_library_operator'))
    
    elif result[0] == 'Cannot delete review. Invalid review ID.':
        error = 'Cannot delete review.'
        flash(error, 'delete_error')
        return redirect(url_for('view_reviews_library_operator'))


@app.route('/approve_review', methods=['POST'])
def approve_review():

    if 'username' not in session:
        return 'User not logged in.'

    username = session['username']
    review_id = request.form['review_id']
    user_username = request.form['user_username']
    title = request.form['title']
    
    cursor = mysql.connection.cursor()
    cursor.callproc('approve_review', (username, user_username, title, review_id))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Flash the result message
    if result[0] == 'Review approved successfully.':
        success = 'Review approved successfully.'
        flash(success, 'approve_success')
        return redirect(url_for('view_reviews_library_operator'))
    
    elif result[0] == 'Something went wrong with the approval.':
        error = 'Something went wrong with the approval.'
        flash(error, 'approve_error')
        return redirect(url_for('view_reviews_library_operator'))
    
    elif result[0] == 'This review does not concern a book that belongs to your school.':
        error = 'This review does not concern a book that belongs to your school.'
        flash(error, 'approve_error')
        return redirect(url_for('view_reviews_library_operator'))
    
    elif result[0] == 'You do not belong to the same school as the user whose review you want to approve.':
        error = 'You do not belong to the same school as the user whose review you want to approve.'
        flash(error, 'approve_error')
        return redirect(url_for('view_reviews_library_operator'))
    
    elif result[0] == 'Teacher/student does not exist or is not approved.':
        error = 'Teacher/student does not exist or is not approved.'
        flash(error, 'approve_error')
        return redirect(url_for('view_reviews_library_operator'))
    
    elif result[0] == 'You are not an approved library operator.':
        error = 'You are not an approved library operator.'
        flash(error, 'approve_error')
        return redirect(url_for('view_reviews_library_operator'))

    else :
        error = 'Unknown error occurred'
        flash(error, 'approve_error')
        return redirect(url_for('view_reviews_library_operator'))


# The user can see all the reservations they have made
@app.route('/user_reservations')
def user_reservations():
    
    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    username = session['username']

    # Get the error message from the query parameters
    error = get_flashed_messages(category_filter=['cancel_error'])
    success = get_flashed_messages(category_filter=['cancel_success'])
    
    cursor = mysql.connection.cursor()
    cursor.callproc('view_reservations_teacherstudent', (username,))
    result = cursor.fetchall()

    cursor.close()

    reservations_id = []
    #the same procedure is used for the operator to search reservations by username
    #in this case we just "catch" the username and position, but not render them to the user
    u_username = [] 
    u_position =[] 
    book_id = []
    title = []
    reservation_date = []
    status = []

    for row in result:
        reservations_id.append(row[0])
        u_username.append(row[1])
        u_position.append(row[2])
        book_id.append(row[3])
        title.append(row[4])
        reservation_date.append(row[5])
        status.append(row[6])

    return render_template('user_reservations.html', reservations_id=reservations_id, book_id= book_id, 
                           title=title , reservation_date=reservation_date, status=status, error=error, success=success)


#The user can delete their reservatins
@app.route('/cancel_reservation', methods=['POST'])
def cancel_reservation():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    username = session['username']
    reservation_id = request.form['reservation_id']
    
    # Call the cancel_reservation procedure
    cursor = mysql.connection.cursor()
    cursor.callproc('cancel_reservation', (reservation_id, username))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Display the result message
    if result[0] == 'Reservation cancelled successfully.':
        success = 'Reservation cancelled successfully.'
        flash(success, 'cancel_success')
        return redirect(url_for('user_reservations'))
    
    elif result[0] == 'Cannot cancel reservation. Invalid reservation ID or status.':
        error = 'Cannot cancel reservation.'
        flash(error, 'cancel_error')
        return redirect(url_for('user_reservations'))


# The library operator can see all of the reservations made in their school
@app.route('/library_operator_reservations', methods=['GET', 'POST'])
def library_operator_reservations():
   
    if 'username' in session:   

        # Get the user's position from the session
        # to make sure it is the library_operator
        username = session.get('username')
        position = session.get('position')

        if position == 'library_operator':
            
            cursor = mysql.connection.cursor()
            query = "SELECT school_member_username FROM school_member WHERE school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
            cursor.execute(query, (username,))
            usernames = [row[0] for row in cursor.fetchall()]
            cursor.close()

            if request.method == 'POST':
                
                #this means we are searching for a specific username
                searchUsername = request.form.get('searchUsername')

                if not searchUsername:
                    return redirect(url_for('library_operator_reservations'))
                
                cursor = mysql.connection.cursor()
                cursor.callproc('view_reservations_teacherstudent', (searchUsername,))
                result = cursor.fetchall()
                cursor.close()

                reservations_id = []
                u_username = [] 
                u_position =[] 
                book_id = []
                title = []
                reservation_date = []
                status = []

                for row in result:
                    reservations_id.append(row[0])
                    u_username.append(row[1])
                    u_position.append(row[2])
                    book_id.append(row[3])
                    title.append(row[4])
                    reservation_date.append(row[5])
                    status.append(row[6])
                
                return render_template('library_operator_reservations.html',reservations_id=reservations_id, u_username=u_username, 
                            u_position= u_position , book_id= book_id, title=title , reservation_date=reservation_date, status=status, usernames=usernames)


            if request.method == 'GET':

                # Get the error message from the query parameters
                error = get_flashed_messages(category_filter=['accept_error'])
                success = get_flashed_messages(category_filter=['accept_success'])
                
                #Render the template with the all the reservations
                cursor = mysql.connection.cursor()
                cursor.callproc('view_reservations_library_operator', (username,))
                result = cursor.fetchall()
                cursor.close()

                reservations_id = []
                u_username = [] 
                u_position =[] 
                book_id = []
                title = []
                reservation_date = []
                status = []

                for row in result:
                    reservations_id.append(row[0])
                    u_username.append(row[1])
                    u_position.append(row[2])
                    book_id.append(row[3])
                    title.append(row[4])
                    reservation_date.append(row[5])
                    status.append(row[6])
                
                return render_template('library_operator_reservations.html',reservations_id=reservations_id, u_username=u_username, 
                            u_position=u_position , book_id= book_id, title=title , reservation_date=reservation_date, status=status,
                            error = error, success = success, usernames=usernames)
        
        else:
            #it is not the library_operator, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')


# The library operator can accept a reservation and we check internally if the user's loan critiria are met
@app.route('/accept_reservation', methods=['POST'])
def accept_reservation():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    username = session['username']
    reservation_id = request.form['reservation_id']
    u_username = request.form['u_username']
    book_id = request.form['book_id']
    
    # Call the accept_reservation procedure
    cursor = mysql.connection.cursor()
    cursor.callproc('accept_reservation', (username, u_username, reservation_id, book_id))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Flash the result message
    if result[0] == 'Loan recorded successfully.':
        success = 'Loan recorded successfully'
        flash(success, 'accept_success')
        return redirect(url_for('library_operator_reservations'))
    
    elif result[0] == 'Loan criteria not met: User has not returned a book on time':
        error = 'Loan criteria not met: User has not returned a book on time'
        flash(error, 'accept_error')
        return redirect(url_for('library_operator_reservations'))
    
    elif result[0] == 'Loan criteria not met: User has exceeded the limit of loans this week':
        error = 'Loan criteria not met: User has exceeded the limit of loans this week'
        flash(error, 'accept_error')
        return redirect(url_for('library_operator_reservations'))
    
    elif result[0] == 'Book is currently loaned by another user':
        error = 'Book is currently loaned by another user'
        flash(error, 'accept_error')
        return redirect(url_for('library_operator_reservations'))
    
    elif result[0] == 'School member does not exist or is not approved.':
        error = 'School member does not exist or is not approved'
        flash(error, 'accept_error')
        return redirect(url_for('library_operator_reservations'))
    
    elif result[0] == 'Unauthorized library operator.':
        error = 'Unauthorized library operator'
        flash(error, 'accept_error')
        return redirect(url_for('library_operator_reservations'))

    else :
        error = 'Unknown error occurred'
        flash(error, 'accept_error')
        return redirect(url_for('library_operator_reservations'))


# Teacher/Students can see a record of all their loans
@app.route('/user_loans', methods=['GET', 'POST'])
def user_loans():
    if request.method == 'POST':
        return render_template('user_loans.html')

    if request.method == 'GET':
        username = session['username']
        cursor = mysql.connection.cursor()
        cursor.callproc('view_loans_teacherstudent', (username,))
        result = cursor.fetchall()
        cursor.close()

        #the same procedure is used for the operator to search loans by username
        #in this case we just "catch" the username and position, but not render them to the user
        reservations_id = []
        u_username = [] 
        u_position =[] 
        book_id = []
        title = []
        borrow_date = []
        due_date = []
        returned_date = []
        returned =[]

        for row in result:
            reservations_id.append(row[0])
            u_username.append(row[1])
            u_position.append(row[2])
            book_id.append(row[3])
            title.append(row[4])
            borrow_date.append(row[5])
            due_date.append(row[6])
            returned_date.append(row[7])
            returned.append(row[8])

        return render_template('user_loans.html', book_id= book_id, title=title , borrow_date=borrow_date, due_date=due_date,
                            returned_date=returned_date, returned=returned)
    

# The library operator can see and manage all the loans in their school
@app.route('/library_operator_loans', methods=['GET', 'POST'])
def library_operator_loans():
   
    if 'username' in session:   

        # Get the user's position from the session
        # to make sure it is the library_operator
        username = session.get('username')
        position = session.get('position')

        if position == 'library_operator':

            cursor = mysql.connection.cursor()
            query = "SELECT school_member_username FROM school_member WHERE school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
            cursor.execute(query, (username,))
            usernames = [row[0] for row in cursor.fetchall()]
            cursor.close()

            if request.method == 'POST':
                
                #this means we are searching for a specific username
                searchUsername = request.form.get('searchUsername')

                if not searchUsername:
                    return redirect(url_for('library_operator_loans'))
                
                cursor = mysql.connection.cursor()
                cursor.callproc('view_loans_teacherstudent', (searchUsername,))
                result = cursor.fetchall()
                cursor.close()

                reservations_id = []
                u_username = [] 
                u_position =[] 
                book_id = []
                title = []
                borrow_date = []
                due_date = []
                returned_date = []
                returned =[]

                for row in result:
                    reservations_id.append(row[0])
                    u_username.append(row[1])
                    u_position.append(row[2])
                    book_id.append(row[3])
                    title.append(row[4])
                    borrow_date.append(row[5])
                    due_date.append(row[6])
                    returned_date.append(row[7])
                    returned.append(row[8])
                
                return render_template('library_operator_loans.html',reservations_id=reservations_id, u_username=u_username, 
                            u_position= u_position , book_id= book_id, title=title , borrow_date=borrow_date, due_date=due_date,
                            returned_date=returned_date, returned=returned, usernames=usernames)


            if request.method == 'GET':

                # Get the error message from the query parameters
                error = get_flashed_messages(category_filter=['return_error'])
                success = get_flashed_messages(category_filter=['return_success'])
                
                #Render the template with the all the loans
                cursor = mysql.connection.cursor()
                cursor.callproc('view_loans_library_operator', (username,))
                result = cursor.fetchall()
                cursor.close()

                reservations_id = []
                u_username = [] 
                u_position =[] 
                book_id = []
                title = []
                borrow_date = []
                due_date = []
                returned_date = []
                returned =[]

                for row in result:
                    reservations_id.append(row[0])
                    u_username.append(row[1])
                    u_position.append(row[2])
                    book_id.append(row[3])
                    title.append(row[4])
                    borrow_date.append(row[5])
                    due_date.append(row[6])
                    returned_date.append(row[7])
                    returned.append(row[8])
                
                return render_template('library_operator_loans.html',reservations_id=reservations_id, u_username=u_username, 
                            u_position=u_position , book_id= book_id, title=title , borrow_date=borrow_date, due_date=due_date,
                            returned_date=returned_date , returned=returned, error = error, success = success, usernames=usernames)
        
        else:
            #it is not the library_operator, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')


# The library operator can record the return of a copy
@app.route('/record_return', methods=['POST'])
def record_return():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    username = session['username']
    reservation_id = request.form['reservation_id']
    
    # Call the record_return procedure
    cursor = mysql.connection.cursor()
    cursor.callproc('record_returned_books', (reservation_id, username))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Flash the result message
    if result[0] == 'Returned date recorded successfully.':
        success = 'Returned date recorded successfully'
        flash(success, 'return_success')
        return redirect(url_for('library_operator_loans'))
    
    elif result[0] == 'You are not an approved library operator.':
        error = 'You are not an approved library operator.'
        flash(error, 'return_error')
        return redirect(url_for('library_operator_loans'))
    
    elif result[0] == 'Return already recorded.':
        error = 'Return already recorded.'
        flash(error, 'return_error')
        return redirect(url_for('library_operator_loans'))
    
    elif result[0] == 'The reservation ID you entered is not valid.':
        error = 'The reservation ID you entered is not valid.'
        flash(error, 'return_error')
        return redirect(url_for('library_operator_loans'))

    else :
        error = 'Unknown error occurred'
        flash(error, 'return_error')
        return redirect(url_for('library_operator_loans'))


# The library operator can see seperately, a record of all the delayd loans
@app.route('/library_operator_delays')
def library_operator_delays():
   
    if 'username' in session:   

        # Get the user's position from the session
        # to make sure it is the library_operator
        username = session.get('username')
        position = session.get('position')

        if position == 'library_operator':

            cursor = mysql.connection.cursor()
            cursor.callproc('view_delays_library_operator', (username,))
            result = cursor.fetchall()
            cursor.close()

            reservations_id = []
            u_username = [] 
            u_position =[] 
            book_id = []
            title = []
            borrow_date = []
            due_date = []
            returned_date = []
            returned =[]

            for row in result:
                reservations_id.append(row[0])
                u_username.append(row[1])
                u_position.append(row[2])
                book_id.append(row[3])
                title.append(row[4])
                borrow_date.append(row[5])
                due_date.append(row[6])
                returned_date.append(row[7])
                returned.append(row[8])
                
            return render_template('library_operator_delays.html',reservations_id=reservations_id, u_username=u_username, 
                            u_position= u_position , book_id= book_id, title=title , borrow_date=borrow_date, due_date=due_date,
                            returned_date=returned_date, returned=returned)

        
        else:
            #it is not the library_operator, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')


# The library operator can record a loan with out the need for a prior reservation
@app.route('/record_loan_without_reservation', methods=['GET', 'POST'])
def record_loan_without_reservation():

    username = session.get('username')

    cursor = mysql.connection.cursor()
    query = "SELECT school_member_username FROM school_member WHERE school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
    cursor.execute(query, (username,))
    usernames = [row[0] for row in cursor.fetchall()]
    cursor.close()

    cursor = mysql.connection.cursor()
    query = "SELECT b.book_id,b.title FROM book b WHERE b.school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
    cursor.execute(query, (username,))
    result = cursor.fetchall()
    cursor.close()

    book_ids = []

    for row in result:
        book_ids.append(row[0])


    if request.method == 'POST':
        operator_username = session['username']
        user_username = request.form['username']
        my_book_id = request.form['book_id']

        conn = mysql.connection
        cursor = conn.cursor()

        error = None  # Initialize the error variable
        success = None  # Initialize the success variable

        try:
            # Call the SQL procedure
            cursor.callproc('record_loan_without_reservation', (operator_username, user_username, my_book_id))
            result = cursor.fetchone()

            if result:
                message = result[0]
                if message == 'Book is unavailable.':
                    error = 'Book is unavailable!'
                elif message == 'Book does not exist':
                    error = 'Book does not exist in the database of your school!'
                elif message == 'Loan recorded successfully.':
                    success = 'Loan recorded successfully!'
                elif message == 'Loan criteria not met.':
                    error = 'School member''s loan criteria are not met.'
                elif message == 'Unauthorized library operator.':
                    error = 'You are not an authorized library operator!'
                elif message == 'You and the user do not belong to the same school.':
                    error = 'You and the user don''t belong to the same school!'
                elif message == 'School member does not exist or is not approved.':
                    error = 'School member doesn''t exist or is not approved!'
                else:
                    error = 'Unknown error occurred.'
            else:
                error = 'Unknown error occurred.'

            cursor.close()
            conn.commit()


        except Exception as e:
            print(f"Error: {e}")
            error = 'Unknown error occurred.'

        # Render the login page with the error message
        return render_template('record_loan_without_reservation.html', error=error, success=success, usernames=usernames, book_ids=book_ids)

    return render_template('record_loan_without_reservation.html', usernames=usernames,book_ids=book_ids)


# The library operator can see all the users and manage them
@app.route('/view_users', methods=['GET', 'POST'])
def view_users():
   
    if 'username' in session:   

        # Get the user's position from the session
        # to make sure it is the library_operator
        username = session.get('username')
        position = session.get('position')

        if position == 'library_operator':
            
            cursor = mysql.connection.cursor()
            query = "SELECT school_member_username FROM school_member WHERE school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
            cursor.execute(query, (username,))
            usernames = [row[0] for row in cursor.fetchall()]
            cursor.close()

            cursor = mysql.connection.cursor()
            query = "SELECT school_member_username FROM school_member WHERE school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
            cursor.execute(query, (username,))
            usernames = [row[0] for row in cursor.fetchall()]
            cursor.close()

            if request.method == 'POST':
                
                #this means we are searching for a specific username
                searchUsername = request.form.get('searchUsername')

                if not searchUsername:
                    return redirect(url_for('view_users'))
                
                cursor = mysql.connection.cursor()
                cursor.callproc('search_user', (searchUsername,))
                result = cursor.fetchall()
                cursor.close()

                u_username = [searchUsername]
                u_position =[] 
                first_name = []
                last_name = []
                status = []

                for row in result:
                    u_position.append(row[0])
                    first_name.append(row[1])
                    last_name.append(row[2])
                    status.append(row[3])
                
                return render_template('view_users.html',u_username=u_username, u_position= u_position, 
                                        first_name=first_name, last_name=last_name, status=status, usernames=usernames)


            if request.method == 'GET':

                # Get the error message from the query parameters
                error_categories = ['accept_error', 'reject_error', 'delete_error', 'disable_error']
                error = get_flashed_messages(category_filter=error_categories)
    
                success_categories = ['accept_success', 'reject_success', 'delete_success', 'disable_success' ]
                success = get_flashed_messages(category_filter=success_categories)
                
                #Render the template with the all the reservations
                cursor = mysql.connection.cursor()
                cursor.callproc('search_user_from_library_operator', (username,))
                result = cursor.fetchall()
                cursor.close()

                u_username = []
                u_position =[] 
                first_name = []
                last_name = []
                status = []

                for row in result:
                    u_username.append(row[0])
                    u_position.append(row[1])
                    first_name.append(row[2])
                    last_name.append(row[3])
                    status.append(row[4])
                
                return render_template('view_users.html',u_username=u_username, u_position= u_position, first_name=first_name, last_name=last_name,
                                        status=status, error = error, success = success, usernames=usernames)
        
        else:
            #it is not the library_operator, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')


# The library operator can see their information
@app.route('/user_info_library_operator', methods=['POST'])
def user_info_library_operator():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    u_username = request.form['u_username']

    cursor = mysql.connection.cursor()
    cursor.callproc('view_user_information', [u_username])
    result = cursor.fetchall()

    cursor.close()

    if len(result) == 0:
        return 'User not found.'

    return render_template('user_info_library_operator.html', user=result[0])



@app.route('/accept_user', methods=['POST'])
def accept_user():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    username = session['username']
    u_username = request.form['u_username']
    
    # Call the approve_user procedure
    cursor = mysql.connection.cursor()
    cursor.callproc('approve_user', (u_username, username,))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Flash the result message
    if result[0] == 'User approved successfully.':
        success = 'User approved successfully'
        flash(success, 'accept_success')
        return redirect(url_for('view_users'))
    
    elif result[0] == 'You are not an approved library operator.':
        error = 'You are not an approved library operator.'
        flash(error, 'accept_error')
        return redirect(url_for('view_users'))

    else :
        error = 'Unknown error occurred'
        flash(error, 'accept_error')
        return redirect(url_for('view_users'))


#For use, deleting a user and rejecting their registration is the same thing
#So both buttons in the "view_users.html" redirect here
@app.route('/delete_user', methods=['POST'])
def delete_user():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    username = session['username']
    u_username = request.form['u_username']
    
    # Call the delete_teacher_student procedure
    cursor = mysql.connection.cursor()
    cursor.callproc('delete_teacher_student', (username, u_username))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Flash the result message
    if result[0] == 'School member deleted successfully.':
        success = 'School member deleted successfully.'
        flash(success, 'delete_success')
        return redirect(url_for('view_users'))
    
    elif result[0] == 'User has not yet returned a book!':
        error = 'User has not yet returned a book!'
        flash(error, 'delete_error')
        return redirect(url_for('view_users'))
    
    elif result[0] == 'Operator and member belong to different schools.':
        error = 'Operator and member belong to different schools.'
        flash(error, 'delete_error')
        return redirect(url_for('view_users'))
    
    elif result[0] == 'Operator not approved.':
        error = 'Operator not approved.'
        flash(error, 'delete_error')
        return redirect(url_for('view_users'))

    else :
        error = 'Unknown error occurred'
        flash(error, 'delete_error')
        return redirect(url_for('view_users'))
    


@app.route('/disable_user', methods=['POST'])
def disable_user():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    username = session['username']
    u_username = request.form['u_username']
    
    # Call the disable_teacherstudent procedure
    cursor = mysql.connection.cursor()
    cursor.callproc('disable_teacherstudent', (username, u_username))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Flash the result message
    if result[0] == 'School member account disabled successfully.':
        success = 'School member account disabled successfully.'
        flash(success, 'disable_success')
        return redirect(url_for('view_users'))
    
    elif result[0] == 'Library operator and member belong to different schools.':
        error = 'Library operator and member belong to different schools.'
        flash(error, 'disable_error')
        return redirect(url_for('view_users'))
    
    elif result[0] == 'Library operator is not approved.':
        error = 'Library operator is not approved.'
        flash(error, 'disable_error')
        return redirect(url_for('view_users'))

    else :
        error = 'Unknown error occurred'
        flash(error, 'disable_error')
        return redirect(url_for('view_users'))



@app.route('/view_library_operators', methods=['GET', 'POST'])
def view_library_operators():
   
    if 'username' in session:   

        # Get the user's position from the session
        # to make sure it is the admin
        username = session.get('username')
        position = session.get('position')

        if position == 'admin':
            
            cursor = mysql.connection.cursor()
            query = "SELECT library_operator_username FROM library_operator"
            cursor.execute(query)
            usernames = [row[0] for row in cursor.fetchall()]
            cursor.close()

            if request.method == 'POST':
                
                #this means we are searching for a specific username
                searchUsername = request.form.get('searchUsername')

                if not searchUsername:
                    return redirect(url_for('view_library_operators'))
                
                cursor = mysql.connection.cursor()
                cursor.callproc('search_library_operator', (searchUsername,))
                result = cursor.fetchall()
                cursor.close()

                u_username = []
                first_name = []
                last_name = []
                school = []
                status = []

                for row in result:
                    u_username.append(row[0])
                    first_name.append(row[1])
                    last_name.append(row[2])
                    school.append(row[3])
                    status.append(row[4])
                
                return render_template('view_library_operators.html',u_username=u_username, first_name=first_name, last_name=last_name, 
                                       school=school,  status=status, usernames=usernames)


            if request.method == 'GET':

                # Get the error message from the query parameters
                error_categories = ['accept_error', 'delete_error', 'disable_error']
                error = get_flashed_messages(category_filter=error_categories)
    
                success_categories = ['accept_success', 'delete_success', 'disable_success' ]
                success = get_flashed_messages(category_filter=success_categories)
                
                #Render the template with the all the library_operators
                cursor = mysql.connection.cursor()
                query = "SELECT u.username,s.school_name, u.first_name, u.last_name, l.approved FROM user u INNER JOIN school_member s ON u.username = s.school_member_username INNER JOIN library_operator l ON l.library_operator_username = u.username"
                cursor.execute(query)
                result = cursor.fetchall()
                cursor.close()

                u_username = []
                first_name = []
                last_name = []
                school = []
                status = []

                for row in result:
                    u_username.append(row[0])
                    first_name.append(row[2])
                    last_name.append(row[3])
                    school.append(row[1])
                    status.append(row[4])
                
                return render_template('view_library_operators.html',u_username=u_username, first_name=first_name, last_name=last_name, school=school,
                                        status=status, error = error, success = success, usernames=usernames)
        
        else:
            #it is not the admin, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')


@app.route('/accept_library_operator', methods=['POST'])
def accept_library_operator():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    username = session['username']
    u_username = request.form['u_username']
    
    # Call the accept_library_operator procedure
    cursor = mysql.connection.cursor()
    cursor.callproc('approve_library_operator', (username, u_username))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Flash the result message
    if result[0] == 'Library operator updated successfully!':
        success = 'Library operator updated successfully!'
        flash(success, 'accept_success')
        return redirect(url_for('view_library_operators'))
    
    elif result[0] == 'There is already an approved library operator in this school!':
        error = 'There is already an approved library operator in this school!'
        flash(error, 'accept_error')
        return redirect(url_for('view_library_operators'))
    
    elif result[0] == 'You are not authorized to approve an operator.':
        error = 'You are not authorized to approve an operator.'
        flash(error, 'accept_error')
        return redirect(url_for('view_library_operators'))

    else :
        error = 'Unknown error occurred'
        flash(error, 'accept_error')
        return redirect(url_for('view_library_operators'))



@app.route('/delete_library_operator', methods=['POST'])
def delete_library_operator():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    username = session['username']
    u_username = request.form['u_username']
    
    # Call the delete_library_operator procedure
    cursor = mysql.connection.cursor()
    cursor.callproc('delete_library_operator', (u_username,))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Flash the result message
    if result[0] == 'School member deleted successfully.':
        success = 'School member deleted successfully.'
        flash(success, 'delete_success')
        return redirect(url_for('view_library_operators'))

    else :
        error = 'Unknown error occurred'
        flash(error, 'delete_error')
        return redirect(url_for('view_library_operators'))
    


@app.route('/disable_library_operator', methods=['POST'])
def disable_library_operator():

    if 'username' not in session:
        #user not logged in
        return redirect('/login_form')

    username = session['username']
    u_username = request.form['u_username']
    
    # Call the disable_library_operator procedure
    cursor = mysql.connection.cursor()
    cursor.callproc('disable_library_operator', (username, u_username))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()
    
    # Flash the result message
    if result[0] == 'Library operator disabled successfully.':
        success = 'Library operator disabled successfully.'
        flash(success, 'disable_success')
        return redirect(url_for('view_library_operators'))
    
    elif result[0] == 'You are not authorized to disable operators.':
        error = 'You are not authorized to disable operators.'
        flash(error, 'disable_error')
        return redirect(url_for('view_library_operators'))

    else :
        error = 'Unknown error occurred'
        flash(error, 'disable_error')
        return redirect(url_for('view_library_operators'))


# Following are the queries specified for the Admin
@app.route('/query_3_1_1', methods=['GET', 'POST'])
def query_3_1_1():

    if 'username' in session:

        # Get the user's position from the session
        # to make sure it is the admin
        position = session.get('position')

        if position == 'admin':

            if request.method == 'POST':
                
                searchYear = request.form.get('year')
                searchMonth = request.form.get('month')

                if not searchYear:
                    searchYear = None

                if not searchMonth:
                    searchMonth = None

                cursor = mysql.connection.cursor()
                cursor.callproc('search_loans_per_school', (searchYear, searchMonth))
                result = cursor.fetchall()
                cursor.close()

                school_name= []
                loans = []

                for row in result:

                    school_name.append(row[0])
                    loans.append(row[1])
                
                return render_template('query_3_1_1.html',school_name=school_name, loans=loans)
                
            if request.method == 'GET':
                
                #Render the template with the total number of loans per school
                cursor = mysql.connection.cursor()
                cursor.callproc('search_loans_per_school', (None, None))
                result = cursor.fetchall()
                cursor.close()

                school_name= []
                loans = []

                for row in result:

                    school_name.append(row[0])
                    loans.append(row[1])
                
                return render_template('query_3_1_1.html',school_name=school_name, loans=loans)
        
        else:
            #it is not the admin, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')
    



@app.route('/query_3_1_2', methods=['GET', 'POST'])
def query_3_1_2():

    if 'username' in session:

        # Get the user's position from the session
        # to make sure it is the admin
        position = session.get('position')

        cursor = mysql.connection.cursor()
        query = "SELECT DISTINCT c.category FROM book_category c"
        cursor.execute(query)
        categories = [row[0] for row in cursor.fetchall()]
        cursor.close()

        if position == 'admin':

            if request.method == 'POST':
                
                category = request.form.get('category')

                cursor = mysql.connection.cursor()
                cursor.callproc('search_teachers_per_book_loaned_category', (category,))
                result = cursor.fetchall()
                cursor.close()

                t_username= []
                t_first_name = []
                t_last_name = []

                for row in result:

                    t_username.append(row[0])
                    t_first_name.append(row[1])
                    t_last_name.append(row[2])

                cursor = mysql.connection.cursor()
                cursor.callproc('search_authors_per_category', (category,))
                result_a = cursor.fetchall()
                cursor.close()

                authors=[]

                for row in result_a:

                    authors.append(row)

                return render_template('query_3_1_2.html', username = t_username, first_name = t_first_name, last_name = t_last_name, authors=authors, categories=categories)
    
                
            if request.method == 'GET':
                
                #Render the template
                return render_template('query_3_1_2.html', categories = categories)
        
        else:
            #it is not the admin, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')



@app.route('/query_3_1_3')
def query_3_1_3():

    if 'username' in session:

        # Get the user's position from the session
        # to make sure it is the admin
        position = session.get('position')

        if position == 'admin':

            cursor = mysql.connection.cursor()
                
            cursor.callproc('young_teachers_most_reserves')
            result = cursor.fetchall()
            cursor.close()

            t_username= []
            t_first_name = []
            t_last_name = []
            t_number = []

            for row in result:

                t_username.append(row[0])
                t_first_name.append(row[1])
                t_last_name.append(row[2])
                t_number.append(row[3])

            return render_template('query_3_1_3.html', username = t_username, first_name = t_first_name, last_name = t_last_name, number = t_number)
        
        else:
            #it is not the admin, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')




@app.route('/query_3_1_4')
def query_3_1_4():

    if 'username' in session:

        # Get the user's position from the session
        # to make sure it is the admin
        position = session.get('position')

        if position == 'admin':

            cursor = mysql.connection.cursor()
                
            cursor.callproc('find_authors_not_borrowed')
            result = cursor.fetchall()
            cursor.close()

            authors=[]
            for row in result:

                authors.append(row)

            return render_template('query_3_1_4.html',authors=authors)
        else:
            #it is not the admin, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')



@app.route('/query_3_1_5', methods=['GET', 'POST'])
def query_3_1_5():

    if 'username' in session:

        # Get the user's position from the session
        # to make sure it is the admin
        position = session.get('position')

        if position == 'admin':

            if request.method == 'POST':
                
                year = request.form.get('year')

                cursor = mysql.connection.cursor()
                cursor.callproc('search_operators_num_of_loans_per_year', (year,))
                result = cursor.fetchall()
                cursor.close()

                loans= []
                operator_number = []
                operators = []

                for row in result:

                    loans.append(row[0])
                    operator_number.append(row[1])
                    operators.append(row[2])

                return render_template('query_3_1_5.html', loans = loans, operator_number = operator_number, operators = operators)
    
                
            if request.method == 'GET':
                
                #Render the template
                return render_template('query_3_1_5.html')
        
        else:
            #it is not the admin, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')


@app.route('/query_3_1_6')
def query_3_1_6():
    if 'username' in session:

        # Get the user's position from the session
        # to make sure it is the admin
        position = session.get('position')

        if position == 'admin':
            cursor = mysql.connection.cursor()

            cursor.callproc('most_famous_field_pair')
            result = cursor.fetchall()
            cursor.close()
            first_category=[]
            second_category=[]
            for row in result:

                first_category.append(row[0])
                second_category.append(row[1])

            return render_template('query_3_1_6.html',first_category=first_category, second_category=second_category)
        else:
            #it is not the admin, redirect them to their homepage
            return redirect('/homepage')


@app.route('/query_3_1_7')
def query_3_1_7():

    if 'username' in session:

        # Get the user's position from the session
        # to make sure it is the admin
        position = session.get('position')

        if position == 'admin':

            cursor = mysql.connection.cursor()
                
            cursor.callproc('find_authors_with_less_books')
            result = cursor.fetchall()
            cursor.close()

            authors=[]
            books=[]

            for row in result:

                authors.append(row[0])
                books.append(row[1])

            return render_template('query_3_1_7.html',authors=authors, books=books)
        else:
            #it is not the admin, redirect them to their homepage
            return redirect('/homepage')
    
    else :
        #user not logged in
        return redirect('/login_form')


# Folowing are the queries specified for the Library Operator
@app.route('/query_3_2_1', methods=['GET', 'POST'])
def query_3_2_1():
    if request.method == 'POST':
        title_query = request.form.get('title_query')
        category_query = request.form.get('category_query')
        author_query = request.form.get('author_query')
        copies_query = request.form.get('copies_query')
        username = session['username']
        book_titles=[]
        book_authors=[]
        
        if not copies_query:
            copies_query = None
        
        if title_query or author_query or category_query or copies_query:
            cursor = mysql.connection.cursor()
            cursor.callproc('search_books_library_operator', (username, title_query or None, category_query or None, author_query or None, copies_query or None))
            result = cursor.fetchall()
            cursor.close()
            for row in result:
                book_titles.append(row[0])
                book_authors.append(row[1])
            
            
        return render_template('query_3_2_1.html', book_titles=book_titles, book_authors=book_authors)    

    if request.method == 'GET':
        username= session['username']
        cursor = mysql.connection.cursor()
        
        cursor.callproc('search_books_library_operator', (username, None, None, None, None))
        result = cursor.fetchall()
        cursor.close()
        book_titles=[]
        book_authors=[]
        for row in result:
            book_titles.append(row[0])
            book_authors.append(row[1])

    return render_template('query_3_2_1.html', book_titles=book_titles, book_authors=book_authors)


@app.route('/book_details_library_operator')
def book_details_library_operator():
    if 'username' not in session:
        return 'User not logged in.'

    username = session['username']
    title = request.args.get('title')

    cursor = mysql.connection.cursor()
    cursor.callproc('view_book_details_library_operator', (username,title))

    result = cursor.fetchall()

    cursor.close()

    if len(result) == 0:
        return 'PROBLEMMMMM.'
    books = []
    book_ids = []
    status_list = []

    for row in result:
        book_title = title
        if len(row) > 0:
            book_ISBN = row[0]
        if len(row) > 1:
            book_pages_number = row[1]
        if len(row) > 2:
            book_publisher = row[2]
        if len(row) > 3:
            book_summary = row[3]
        if len(row) > 4:
            book_language = row[4]

        book = {
            'ISBN': book_ISBN,
            'title': book_title,
            'pages_number': book_pages_number,
            'publisher': book_publisher,
            'summary': book_summary,
            'language': book_language
        }
        books.append(book)

        cursor = mysql.connection.cursor()
        query = "SELECT book_id FROM book WHERE ISBN = %s AND title = %s AND pages_number = %s AND publisher = %s AND summary = %s AND language = %s AND school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
        cursor.execute(query, (book_ISBN, book_title, book_pages_number, book_publisher, book_summary, book_language, username))
        result = cursor.fetchall()

        book_id_list = []
        status_sublist = []

        for row in result:
            book_id = row[0]
            book_id_list.append(book_id)

            query = "SELECT 1 FROM reserves WHERE book_id = %s AND returned_date IS NULL"
            cursor.execute(query, (book_id,))
            if cursor.rowcount > 0:
                status = 'Reserved'
                status_sublist.append(status)
            else:
                status = 'Available'
                status_sublist.append(status)

        book_ids.append(book_id_list)
        status_list.append(status_sublist)

        cursor.close()

    
    #Authors        
    cursor = mysql.connection.cursor()
    cursor.callproc('view_book_authors_teacherstudent', (username,title))
    result = cursor.fetchall()  
    cursor.close()
    book_authors= [row[0] for row in result]
    
    #Categories
    cursor = mysql.connection.cursor()
    cursor.callproc('view_book_categories_teacherstudent', (username,title))
    result = cursor.fetchall()  
    cursor.close()
    book_categories= [row[0] for row in result]
    
    #Keywords
    cursor = mysql.connection.cursor()
    cursor.callproc('view_book_keywords_teacherstudent', (username,title))
    result = cursor.fetchall()  
    cursor.close()
    book_keywords= [row[0] for row in result]

    error = get_flashed_messages(category_filter=['delete_error'])
    success = get_flashed_messages(category_filter=['delete_success'])

    return render_template('book_details_library_operator.html', books=books, book_ids=book_ids, status_list=status_list, book_authors = book_authors, 
                           book_categories= book_categories, book_keywords = book_keywords, error=error, success=success)


@app.route('/update_book_information', methods=['GET', 'POST'])
def update_book_information():
    if request.method == 'GET':
            
        book_id = request.args.get('book_id')
        cur = mysql.connection.cursor()
        cur.callproc('get_book_information', (book_id,))
        book_data = cur.fetchone()
        cur.close()

        if book_data:
            return render_template('update_book_information.html', book_id=book_id, book_data=book_data)
        else:
            return "Book not found."
    
    elif request.method == 'POST':
     #book_id = request.args.get('book_id')
     book_id = request.form['book_id']
     new_isbn = request.form['ISBN']
     new_title = request.form['title']
     new_authors = request.form['author_name']
     new_categories = request.form['category']
     new_pages_number = request.form['pages_number']
     new_publisher = request.form['publisher']
     new_summary = request.form['summary']
     new_language = request.form['language']
     new_keywords = request.form['keyword']
     cover=request.files['image']
     cover_data=cover.read()
     encoded_cover = base64.b64encode(cover_data).decode('utf-8')
     library_operator_username = session['username']
     cursor = mysql.connection.cursor()
     args=(book_id, new_isbn, new_title, new_pages_number, new_publisher, new_summary, encoded_cover, library_operator_username, new_language, new_authors, new_categories, new_keywords)
     cursor.callproc('update_book', args=args)
     cursor.nextset()  # Skip to the next result set
     mysql.connection.commit()
     cursor.close()
        
     success =  "Book updated successfully."
     cur = mysql.connection.cursor()
     cur.callproc('get_book_information', (book_id,))
     book_data = cur.fetchone()
     cur.close()
     return render_template("update_book_information.html", book_id=book_id, book_data=book_data, success=success)

    
    return render_template("update_book_information.html")


@app.route('/delete_book/<int:book_id>', methods=['GET', 'POST'])
def delete_book(book_id):

    
    curr =  mysql.connection.cursor()
    curr.execute("SELECT title FROM book WHERE book_id = %s", (book_id,))
    title = curr.fetchone()
    curr.close()

    cursor = mysql.connection.cursor()

    cursor.callproc("delete_book", (book_id,))
    result = cursor.fetchone()
    cursor.close()
    mysql.connection.commit()

    # Flash the result message
    if result[0] =='Book deleted successfully.':
        success = 'Book deleted successfully.'
        flash(success, 'delete_success')
        return redirect(url_for('book_details_library_operator', title=title))
    
    elif result[0] == 'This book is either reserved or loaned!':
        error = 'This book is either reserved or loaned!'
        flash(error, 'delete_error')
        return redirect(url_for('book_details_library_operator', title=title))

    else :
        error = 'Unknown error occurred'
        flash(error, 'return_error')
        print(error)
        return redirect(url_for('book_details_library_operator', title=title))



@app.route('/query_3_2_2', methods=['GET', 'POST'])
def query_3_2_2():
    if request.method == 'POST':
        first_name_query = request.form.get('first_name_query')
        last_name_query = request.form.get('last_name_query')
        days_delayed_query = request.form.get('days_delayed_query')
        username = session['username']
        user_username = []
        first_name = []
        last_name = []
        days_delayed = []

        # Convert empty string to None for days_delayed_query
        if not days_delayed_query:
            days_delayed_query = None

        # Perform the search if any query is provided
        if first_name_query or last_name_query or days_delayed_query:
            cursor = mysql.connection.cursor()
            cursor.callproc('search_borrowers_with_delayed_returns', (username, first_name_query or None, last_name_query or None, days_delayed_query or None))

            result = cursor.fetchall()
            cursor.close()
            for row in result:
                user_username.append(row[0])
                first_name.append(row[1])
                last_name.append(row[2])
                days_delayed.append(row[3])

        return render_template('query_3_2_2.html', user_username=user_username, first_name=first_name, last_name=last_name, days_delayed=days_delayed)


    if request.method == 'GET':
        username= session['username']
        cursor = mysql.connection.cursor()
        
        cursor.callproc('search_borrowers_with_delayed_returns', (username, None, None, None))
        result = cursor.fetchall()
        cursor.close()
        user_username=[]
        first_name=[]
        last_name = []
        days_delayed = []
        for row in result:
            user_username.append(row[0])
            first_name.append(row[1])
            last_name.append(row[2])
            days_delayed.append(row[3])

        return render_template('query_3_2_2.html', user_username=user_username, first_name=first_name, last_name=last_name, days_delayed=days_delayed)


def max_length(list1, list2):
    return max(len(list1), len(list2))


@app.template_filter('max_length')
def max_length_filter(*args):
    lengths = [len(arg) for arg in args]
    return max(lengths)


@app.route('/query_3_2_3', methods=['GET', 'POST'])
def query_3_2_3():
    username = session['username']
    cursor = mysql.connection.cursor()
    query = "SELECT school_member_username FROM school_member WHERE school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
    cursor.execute(query, (username,))
    usernames = [row[0] for row in cursor.fetchall()]
    cursor.close()
    
    cursor = mysql.connection.cursor()
    query = "SELECT DISTINCT c.category FROM book_category c JOIN book b ON c.book_id=b.book_id  WHERE b.school_name = (SELECT school_name FROM school_member WHERE school_member_username = %s)"
    cursor.execute(query, (username,))
    categories = [row[0] for row in cursor.fetchall()]
    cursor.close()
    
    if request.method == 'GET':
        username= session['username']
        cursor = mysql.connection.cursor()
        cursor.callproc('user_average_rating', (username, None))
        result = cursor.fetchall()
        cursor.close()
        user_username = []
        average_user_rating = []
        for row in result:
            user_username.append(row[0])
            average_user_rating.append(row[1])
            
        cursor = mysql.connection.cursor()
        cursor.callproc('category_average_rating', (username, None))
        result = cursor.fetchall()
        cursor.close()
        category = []
        average_category_rating = []
        for row in result:
            category.append(row[0])
            average_category_rating.append(row[1])
    
        return render_template('query_3_2_3.html', user_username=user_username, average_user_rating=average_user_rating, category=category, average_category_rating=average_category_rating, usernames= usernames, categories =categories)
    
    if request.method == 'POST':
        user_query = request.form.get('user_query')
        category_query = request.form.get('category_query')
        username = session['username']
        if user_query and not category_query:
            cursor = mysql.connection.cursor()
            cursor.callproc('user_average_rating', (username, user_query))
            result = cursor.fetchall()
            cursor.close()
            user_username = []
            average_user_rating = []
            for row in result:
                user_username.append(row[0])
                average_user_rating.append(row[1])
            return render_template('query_3_2_3.html', user_username=user_username, average_user_rating=average_user_rating, usernames= usernames, categories =categories)
        
        if category_query and not user_query:
            cursor = mysql.connection.cursor()
            cursor.callproc('category_average_rating', (username, category_query))
            result = cursor.fetchall()
            cursor.close()
            category = []
            average_category_rating = []
            for row in result:
                category.append(row[0])
                average_category_rating.append(row[1])
            return render_template('query_3_2_3.html', category=category, average_category_rating=average_category_rating, usernames= usernames, categories =categories)
        
        if user_query and category_query:  
            cursor = mysql.connection.cursor()
            cursor.callproc('average_user_rating_per_category', (username, user_query, category_query))
            result = cursor.fetchall()
            cursor.close()
            user_username = []
            category=[]
            average_rating = []
            for row in result:
                user_username.append(row[0])
                category.append(row[1])
                average_rating.append(row[2])
            return render_template('query_3_2_3_sec.html', user_username=user_username, category=category, average_rating=average_rating, usernames= usernames, categories =categories)
        
        if not user_query and not category_query:
            return redirect(url_for('query_3_2_3', _method='GET'))


# The back up procedure. The user of the web application must change the "BACKUP_PATH" and the paths
# here to properly reflect the paths on their computer
@app.route('/api/backup_database', methods=['GET'])

def perform_backup():
        
    DB_HOST = 'localhost' 
    DB_USER = 'root'
    DB_USER_PASSWORD = ''
    DB_NAME = 'Library_Management_System'
    BACKUP_PATH = r'C:\Users\user\Library_management_system\backup\dbbackup'

    
    # Getting current DateTime to create the separate backup folder like "20180817-123433".
    DATETIME = time.strftime('%Y%m%d-%H%M%S')
    TODAYBACKUPPATH = BACKUP_PATH + '/' + DATETIME
    
    # Checking if backup folder already exists or not. If not exists will create it.
    try:
        os.stat(TODAYBACKUPPATH)
    except:
        os.makedirs(TODAYBACKUPPATH,exist_ok=True)
       
    db = DB_NAME
    print("Starting backup of database " + DB_NAME)
    mysqldump_cmd = r'C:\Users\user\Library_management_system\backup\dbbackup\mysqldump.exe'  # Replace with your path to mysqldump
    dumpcmd = f'{mysqldump_cmd} -h {DB_HOST} -u {DB_USER} -p{DB_USER_PASSWORD} {db} > "{os.path.join(TODAYBACKUPPATH, db)}.sql"'
    subprocess.call(dumpcmd, shell=True)
    
    success = 'Backup completed successfully! ' + 'Your backups have been created in "' + TODAYBACKUPPATH + '" directory'
    flash(success, "backup_success")

    return redirect(url_for('homepage'))


@app.route('/restore_from_backup')
def show_backup_directories():
    backup_path = r'C:\Users\user\Library_management_system\backup\dbbackup'
    backup_directories = sorted(os.listdir(backup_path), reverse=True)
    return render_template('admin_homepage.html', backup_directories=backup_directories)


@app.route('/api/restore_from_backup', methods = ['POST'])
def restore_database():
    
    if request.method == "POST":
        selected_directory = request.form['backup_directory']
        backup_path = r'C:\Users\user\Library_management_system\backup\dbbackup'
        backup_file_path = os.path.join(backup_path, selected_directory, 'Library_Management_System.sql')
        
        # Perform the database restore operation
        host = 'localhost'
        username = 'root'
        password = ''
        # Create the database if it doesn't exist
        create_db_command = f'mysql -u {username} -p{password} -e "CREATE DATABASE IF NOT EXISTS Library_Management_System_backup;"'
        subprocess.call(create_db_command, shell=True)


        command = f"mysql -h {host} -u {username} -p{password} Library_Management_System_backup < {backup_file_path}"
        os.system(command)

        success = "Database restore completed successfully."
        flash(success, "backup_success")

        return redirect(url_for('homepage'))

# The logout process
@app.route('/logout')
def logout():
    
    session.pop('username',None)
    return redirect('/')


if __name__ == "__main__":
    app.run()
