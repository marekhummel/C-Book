require 'sinatra'
require 'sinatra/reloader' if development?
require_relative "db/sql"


@@backroute = "/"


get '/' do
	erb :home
end


get '/useroverview' do
	@useroverview = sql("SELECT ID, Name, Surname FROM User;")

  	erb :useroverview
end




get '/appointmentoverview' do
 	@appointmentoverview = sql("SELECT Appointment.Title, User.Name, User.Surname, Appointment.Start, Appointment.End " + 
 							   "FROM User, Appointment, UserAppointment " +
 							   "WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID;")

 	erb :appointmentoverview	
end




get '/users/:id' do |id|
	usersql = sql("SELECT Name, Surname FROM User WHERE ID = #{id};")[0]
	@username = usersql["Name"] + " " + usersql["Surname"]
	@userid = id

	@appointments = sql("SELECT Appointment.DI, Appointment.ID, Appointment.Title, User.Name, User.Surname, Appointment.Start, Appointment.End " + 
						"FROM User, Appointment, UserAppointment " + 
						"WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID " +
						"AND User.ID = '#{id}';")

	@contributors = sql("SELECT Appointment.ID, User.Name, User.Surname " +
						"FROM User, Appointment, UserAppointment " + 
						"WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID;")

	@@backroute = "/useroverview"
	erb :user
end



get '/users/:id/new' do
	@userid = params[:id]
	
	@@backroute = "/useroverview"
	erb :newappointment
end



post '/newappointment/' do
	#Erzeuge einen neuen song mit den benannten Parametern:
	title = params[:title]
	startTime = params[:startmonth].to_s + "-" + params[:startday].to_s + "-" + params[:startyear].to_s + " " + params[:starthours].to_s + ":" + params[:startmins].to_s + ":" + params[:startsecs].to_s
	endTime = params[:endmonth].to_s + "-" + params[:endday].to_s + "-" + params[:endyear].to_s + " " + params[:endhours].to_s + ":" + params[:endmins].to_s + ":" + params[:endsecs].to_s
	di = Time.now.to_i

	#Add appointment
	sqlcmd = sql("INSERT INTO Appointment (Title, Start, End, DI) VALUES ('#{title}','#{startTime}','#{endTime}', '#{di}');")

	#Get ID
	id = sql("SELECT ID From Appointment WHERE Appointment.DI = '#{di}';")[0]["ID"]

	#Add userappointment
	sqlcmd2 = sql("INSERT INTO UserAppointment (UserID, AppointmentID) VALUES ('1','#{id}');")

	id = 1 #sqlcmd2[0]["USER."]
	redirect to("/users/#{id}")
end







