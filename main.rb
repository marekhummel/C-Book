require 'sinatra'
require 'sinatra/reloader' if development?

require_relative "db/sql"
require_relative "login"


@@backroute = "/"
@@currentuserid = -1


# Home
get '/' do
	@@backroute = "/"
	erb :home
end




# Overview of all users (admin only)
get '/useroverview' do
	@useroverview = sql("SELECT * FROM User;")

	@@backroute = "/"
  	erb :useroverview
end



# Overview of all appointments (admin only)
get '/appointmentoverview' do
 	@appointmentoverview = sql("SELECT Appointment.Title, User.Name, User.Surname, Appointment.Start, Appointment.End " + 
 							   "FROM User, Appointment, UserAppointment " +
 							   "WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID;")

	@@backroute = "/"
 	erb :appointmentoverview	
end









# Personal overview for a signed in user
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




# Add new appointment for the current user
get '/users/:id/new' do
	@userid = params[:id]
	
	@@backroute = "/users/#{@userid}"
	erb :newappointment
end


# Add the new appointment
post '/newappointment' do
	#concat params
	title = params[:title]
	startTime = DateTime.new(params[:startyear].to_i, params[:startmonth].to_i, params[:startday].to_i, params[:starthours].to_i, params[:startmins].to_i, params[:startsecs].to_i).to_s
	endTime = DateTime.new(params[:endyear].to_i, params[:endmonth].to_i, params[:endday].to_i, params[:endhours].to_i, params[:endmins].to_i, params[:endsecs].to_i).to_s
	di = Time.now.to_i

	#Add appointment
	sqlcmd = sql("INSERT INTO Appointment (Title, Start, End, DI) VALUES ('#{title}','#{startTime}','#{endTime}', '#{di}');")

	#Get Appointment ID
	user_id = @@currentuserid
	app_id = sql("SELECT ID From Appointment WHERE Appointment.DI = '#{di}';")[0]["ID"]


	#Add userappointment
	sqlcmd2 = sql("INSERT INTO UserAppointment (UserID, AppointmentID) VALUES ('#{user_id}','#{app_id}');")


	redirect to("/users/#{user_id}")
end







