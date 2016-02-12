require 'sinatra'
require 'sinatra/reloader' if development?

require_relative "db/sql"
require_relative "login_signup"
require_relative "helper"
require_relative "sqlcmds"




# Home
get '/' do
	#Only show main page when not logged in
	if logged_in? then
		@backroute = "/overview"
		redirect to("/overview")
	else
		@backroute = "/"
		erb :home
	end
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
	userid = session[:current_user]["ID"].to_i

	@appointments = query_appointments_of_user(userid)

	@backroute = "/overview"
	erb :overview
end






# Add new appointment for the current user
get '/appointment/new' do
	@otherusers = sql("SELECT ID, Username, Name, Surname FROM User;").select {|user| user["Username"] != session[:current_user]["Username"]}
	
	@backroute = "/overview"
	erb :appointment_new
end



# Add the new appointment
post '/appointment_new' do
	#concat params
	title = params[:title]
	startTime = DateTime.new(params[:startyear].to_i, params[:startmonth].to_i, params[:startday].to_i, params[:starthours].to_i, params[:startmins].to_i, params[:startsecs].to_i).to_s
	endTime = DateTime.new(params[:endyear].to_i, params[:endmonth].to_i, params[:endday].to_i, params[:endhours].to_i, params[:endmins].to_i, params[:endsecs].to_i).to_s


	#Get all contributors
	conts = [current_user()["ID"]]
	for p in params do
		key = p[0]

		if key.start_with?('cont-') then
			contid = key.split('-')[1].to_i
			conts.push(contid)
		end
	end

	#Add appointment
	insert_appointment(title, startTime, endTime, conts)

	#Redirect
	redirect to("/overview")
end






# Open appointment for editing / deleting and a general better overview
get '/appointment/:id' do
	userid = session[:current_user]["ID"]
	appid = params[:id]

	@appointment = query_appointment(userid, appid)

	@contributors = sql("SELECT User.Name, User.Surname " +
						"FROM User, Appointment, UserAppointment " + 
						"WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID " +
						"AND Appointment.ID = '#{appid}';")


	@backroute = "/overview"
	erb :appointment_detail
end




# Delete the selected appointment
delete '/appointment_delete' do

	#Delete
	id = params[:id]
	delete_appointment(id)

	#Redirect
	redirect to("/overview")
end