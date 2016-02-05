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

def query_appointments(userid)
	sql("SELECT Appointment.ID, Appointment.Title, User.Name, User.Surname, Appointment.Start, Appointment.End " + 
		"FROM User, Appointment, UserAppointment " + 
		"WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID " +
		"AND User.ID = '#{userid}';")
end


def insert_appointment(title, start, finish)
	#Insert appointment
	sql("INSERT INTO Appointment (Title, Start, End) VALUES ('#{title}','#{start}','#{finish}');")
	
	#Add userappointment
	app_id = sql("SELECT * FROM Appointment ORDER BY ID DESC LIMIT 1;")[0]["ID"]
	user_id = current_user()["ID"]

	sql("INSERT INTO UserAppointment (UserID, AppointmentID) VALUES ('#{user_id}','#{app_id}');")
end