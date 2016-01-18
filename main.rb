require 'sinatra'
require 'sinatra/reloader' if development?
require_relative "db/sql"



get '/' do
  	erb :home
end


get '/appointments' do
	#@appointments = sql("SELECT * FROM User;")
	@appointments = sql("SELECT a.Title, u.Name, u.Surname, a.Start, a.End FROM User u, Appointment a, UserAppointment ua WHERE ua.UserID = u.ID AND ua.AppointmentID = a.ID;")
 	erb :appointments	
end
