require 'sinatra'
require 'sinatra/activerecord'
require 'bundler/setup'
require 'sinatra/flash'

set database: "sqlite3:testapp_signin.sqlite3"
require './models/User.rb'

configure(:development){set :database, "sqlite3:testapp_signin.sqlite3"}
enable :sessions

get '/' do 
    erb :home
end

get '/register' do
    if params[:user][:password] != params[:confirm_password]
        flash[:error] = "Passwords do not match!"
        redirect '/register'
        return
    end

    User.create(params[:user])

    redirect '/'

end

get '/feed' do

end

get '/profile' do

end

post '/sign-in' do

end

post '/blog' do 

end

post '/register' do

end