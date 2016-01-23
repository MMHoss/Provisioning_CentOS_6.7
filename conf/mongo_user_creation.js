db = connect('127.0.0.1/admin');
db.addUser(
  {
    user: "Admin",
    pwd: "Admin*Pass",
    roles: [ "userAdminAnyDatabase" ] 
  }
)

db = connect('127.0.0.1/ZupDB');
db.addUser( 
	{ 
	user: "zup_user",
	pwd: "Zu_p455w0rd",
	roles: [ "readWrite", "dbAdmin" ]
	} 
)
