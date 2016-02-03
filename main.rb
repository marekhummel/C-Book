require 'sinatra'
require 'sinatra/reloader' if development?
require_relative "db/sql"


@@backroute = "/"
@@currentuserid = -1


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
	@@currentuserid = id

	@appointments = sql("SELECT Appointment.DI, Appointment.ID, Appointment.Title, User.Name, User.Surname, Appointment.Start, Appointment.End " + 
						"FROM User, Appointment, UserAppointment " + 
						"WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID " +
						"AND User.ID = '#{id}';")

	@contributors = sql("SELECT Appointment.ID, User.Name, User.Surname " +
						"FROM User, Appointment, UserAppointment " + 
						"WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID;")

	@@backroute = "/useroverview"
	erb :users
end



get '/users/:id/new' do
	@userid = params[:id]
	
	@@backroute = "/users/#{@userid}"
	erb :newappointment
end



post '/newappointment/' do
	#concat params
	title = params[:title]
	startTime = DateTime.new(params[:startyear].to_i, params[:startmonth].to_i, params[:startday].to_i, params[:starthours].to_i, params[:startmins].to_i, params[:startsecs].to_i, 1).to_s
	endTime = DateTime.new(params[:endyear].to_i, params[:endmonth].to_i, params[:endday].to_i, params[:endhours].to_i, params[:endmins].to_i, params[:endsecs].to_i, 1).to_s
	di = DateTime.now.to_i

	#Add appointment
	sqlcmd = sql("INSERT INTO Appointment (Title, Start, End, DI) VALUES ('#{title}','#{startTime}','#{endTime}', '#{di}');")

	#Get Appointment ID
	user_id = @@currentuserid
	app_id = sql("SELECT ID From Appointment WHERE Appointment.DI = '#{di}';")[0]["ID"]


	#Add userappointment
	sqlcmd2 = sql("INSERT INTO UserAppointment (UserID, AppointmentID) VALUES ('#{user_id}','#{app_id}');")


	redirect to("/users/#{user_id}")
end







