# **** USERS ****

def query_user(name)
	benutzer = sql("SELECT * FROM User WHERE Username='" + name + "' LIMIT 1;")
	if benutzer.size != 1 then
	    return nil
	else
	    return benutzer[0]
	end
end

def query_user_by_id(id)
	benutzer = sql("SELECT * FROM User WHERE ID='" + id.to_s + "' LIMIT 1;")
	if benutzer.size != 1 then
		return nil
	else
	    return benutzer[0]
	end
end

def insert_user(username, hash, name, surname, bday)
	sql("INSERT INTO User (Username, PWHash, Name, Surname, DateOfBirth) VALUES ('#{username}','#{hash}', '#{name}', '#{surname}', '#{bday}');")
end




# **** APPOINTMENTS ****

def query_appointments_of_user(userid)
	sql("SELECT Appointment.ID, Appointment.Title, User.Name, User.Surname, Appointment.Start, Appointment.End " + 
		"FROM User, Appointment, UserAppointment " + 
		"WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID " +
		"AND User.ID = '#{userid}';")
end


def query_appointment(userid, appid)
	apps = sql("SELECT Appointment.ID, Appointment.Title, User.Name, User.Surname, Appointment.Start, Appointment.End " + 
				"FROM User, Appointment, UserAppointment " + 
				"WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID " +
				"AND User.ID = '#{userid}' AND Appointment.ID = '#{params[:id]}' " + 
				"LIMIT 1;")

	return (apps.size == 1) ? apps[0] : nil
end



def insert_appointment(title, start, finish, contributors)
	#Insert appointment
	sql("INSERT INTO Appointment (Title, Start, End) VALUES ('#{title}','#{start}','#{finish}');")
	

	#Get appointment id
	app_id = sql("SELECT * FROM Appointment ORDER BY ID DESC LIMIT 1;")[0]["ID"]
	
	#Add all contributors
	for id in contributors do
		sql("INSERT INTO UserAppointment (UserID, AppointmentID) VALUES ('#{id}','#{app_id}');")
	end
end



def delete_appointment(id)
	#Delete appointment
	sql ("DELETE FROM Appointment WHERE ID =' #{id}';")

	#Delete userappointments
	sql ("DELETE FROM UserAppointment WHERE AppointmentID = '#{id}';")
end
