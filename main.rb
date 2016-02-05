require 'sinatra'
require 'sinatra/reloader' if development?

require_relative "db/sql"
require_relative "login_signup"
require_relative "helper"
require_relative "sqlcmds"




# Home
get '/' do
	@backroute = "/"
	erb :home
end




# Overview of all users (admin only)
get '/useroverview' do
	@useroverview = sql("SELECT * FROM User;")

	@backroute = "/"
  	erb :useroverview
end



# Overview of all appointments (admin only)
get '/appointmentoverview' do
 	@appointmentoverview = sql("SELECT Appointment.Title, User.Name, User.Surname, Appointment.Start, Appointment.End " + 
 							   "FROM User, Appointment, UserAppointment " +
 							   "WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID;")

	@backroute = "/"
 	erb :appointmentoverview	
end









# Personal overview for a signed in user
get '/overview' do
	usersql = session[:current_user]
	id = usersql["ID"].to_i
	@username = usersql["Name"] + " " + usersql["Surname"]

	@appointments = query_appointments(id)

	@contributors = sql("SELECT Appointment.ID, User.Name, User.Surname " +
						"FROM User, Appointment, UserAppointment " + 
						"WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID;")

	@backroute = "/overview"
	erb :overview
end




# Add new appointment for the current user
get '/overview/new' do
	@userid = current_user()["ID"]
	
	@backroute = "/overview"
	erb :newappointment
end


# Add the new appointment
post '/newappointment' do
	#concat params
	title = params[:title]
	startTime = DateTime.new(params[:startyear].to_i, params[:startmonth].to_i, params[:startday].to_i, params[:starthours].to_i, params[:startmins].to_i, params[:startsecs].to_i).to_s
	endTime = DateTime.new(params[:endyear].to_i, params[:endmonth].to_i, params[:endday].to_i, params[:endhours].to_i, params[:endmins].to_i, params[:endsecs].to_i).to_s

	#Add appointment
	insert_appointment(title, startTime, endTime)

	redirect to("/overview")
end







