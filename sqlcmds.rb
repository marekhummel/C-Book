# **** USERS ****


# Returns a user by name
def query_user(name)
    user = sql("SELECT * FROM User WHERE Username='" + name + "' LIMIT 1;")
    if user.size != 1 then
        return nil
    else
        return user[0]
    end
end



# Inserts a new user in the database
def insert_user(username, hash, name, surname, bday)
    return sql("INSERT INTO User (Username, PWHash, Name, Surname, DateOfBirth, IsAdmin) VALUES ('#{username}','#{hash}', '#{name}', '#{surname}', '#{bday}', '0');")
end






#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------




# **** APPOINTMENTS ****

# Returns all appointments of an user
def query_appointments_of_user(userid)
    sql("SELECT Appointment.ID, Appointment.Title, User.Name, User.Surname, Appointment.Start, Appointment.End " + 
        "FROM User, Appointment, UserAppointment " + 
        "WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID " +
        "AND User.ID = '#{userid}'" +
        "ORDER BY Appointment.Start;")
end


# Returns the appointment of the given appid
def query_appointment(appid)
    apps = sql("SELECT Appointment.ID, Appointment.Title, Appointment.Start, Appointment.End " + 
               "FROM User, Appointment, UserAppointment " + 
               "WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID " +
               "AND Appointment.ID = '#{appid}' " + 
               "LIMIT 1;")

    return (apps.size == 1) ? apps[0] : nil
end


# Creates a new appointment by adding the required data to the database
def insert_appointment(title, start, finish, creator, contributors)

    #Insert appointment
    sql("INSERT INTO Appointment (Title, Start, End) VALUES ('#{title}','#{start}','#{finish}');")
    
    #Get appointment id
    app_id = sql("SELECT * FROM Appointment ORDER BY ID DESC LIMIT 1;")[0]["ID"]
    
    #Add all contributors
    for id in contributors do
        sql("INSERT INTO UserAppointment (UserID, AppointmentID) VALUES ('#{id}','#{app_id}');")
    end
    sql("INSERT INTO UserAppointment (UserID, AppointmentID, UserIsCreator) VALUES ('#{creator}','#{app_id}', '1');")

end


# Removes a user as a contributor from an appointment
def unsubscribe_user_from_appointment(userid, appid) 
    sql ("DELETE FROM UserAppointment WHERE UserID = '#{userid}' AND AppointmentID = '#{appid}';")
end



# Deletes an appointment
def delete_appointment(id)
    #Delete appointment
    sql ("DELETE FROM Appointment WHERE ID =' #{id}';")

    #Delete userappointments
    sql ("DELETE FROM UserAppointment WHERE AppointmentID = '#{id}';")
end


# Updates an appointment
def edit_appointment(id, title, start, finish, creator, contributors)

    #Edit appointment
    sql("UPDATE Appointment SET Title='#{title}', Start='#{start}', End='#{finish}' WHERE ID='#{id}';" )

    #Edit contributors
    sql ("DELETE FROM UserAppointment WHERE AppointmentID = '#{id}';")  #Delete current relations

    for contid in contributors
        sql("INSERT INTO UserAppointment (UserID, AppointmentID) VALUES ('#{contid}','#{id}');")
    end
    sql("INSERT INTO UserAppointment (UserID, AppointmentID, UserIsCreator) VALUES ('#{creator}','#{id}', '1');")
end


# Returns a pseudo appointment
def create_empty_appointment()
    return  {"Title" => "", "Start" => DateTime.now, "End" => DateTime.now}
end
