db = connect('127.0.0.1/ZupDB');
db.addUser( 
	{ 
	user: "<username>",
    pwd: "<password>",
    roles: [ "userAdminAnyDatabase" ] 
	} 
)
