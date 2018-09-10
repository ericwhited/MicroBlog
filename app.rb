require 'sinatra'
require 'sinatra/activerecord'
require 'bundler/setup'
require 'sinatra/flash'
require 'bootstrap'
require './models/user.rb'
require './models/post.rb'
require './models/profile.rb'

# set database: "sqlite3:testapp_signin.sqlite3"

enable :sessions

configure(:development){set :database, "sqlite3:testapp_signin.sqlite3"}

#route to the home page, if there is a signed in user go to the feed when home is clicked.
#if no user logged in, send them to the home page to sign in or make an account.
get '/' do 
    if !session[:user_id]
        erb :home
    else
        redirect '/feed'
    erb :home
    end
end

#route to the register. nothing special.
get '/register' do
    erb :register
end
    
#route to the feed page. if no one is logged in, redirect to the home page.
 # if someone is logged in, the instance variable user is the person logged in. load the
 #feed page.
get '/feed' do
    if !session[:user_id]
        redirect '/'
    else 
        @user = current_user
        erb :feed
    end
end

#route to the logged in user's profile page. If no one is logged in, redirect to the home page to make an account. When linking to an erb inside a folder quotes must be used.
get '/profile/view_profile' do
    if !session[:user_id]
        redirect '/'
    else @user =current_user
        erb :"profile/view_profile"
    
    end
end

#route to see all posts on the site. Anyone can see this. no account needed.
get '/all_posts' do
    @post = Post.all.reverse
    erb :all_posts
end

#route to see a post by clicking it. 
get "/posts/:id" do
    @post = Post.find(params[:id])
    @body = @post.body
    erb :"posts/view_post"
   end

#route to have a logged in user go to the edit a profile page.
get '/profile/edit_profile' do
    if session[:user_id]
        @user = current_user
        erb :"profile/edit_profile"
    else 
        redirect '/'
    end
end

#work in progress, show's the name of all users
get '/all_users' do
    @user = User.all
    erb :all_users
end

#when you clik on the post's link you got to the edit page for that post.
get "/posts/:id/edit" do
  @post = Post.find(params[:id])
  erb :"posts/edit_post"
end
#when you click submit, it updates that post and then redirects the user to see the updated post.
put "/posts/:id" do
    @post = Post.find(params[:id])
    @post.update(params[:post])
    redirect "/posts/#{@post.id}"
  end
#on home page, sign in, if the passwords dont mage you get the message telling you they dont match and try again. redirects you to the feed page if sucessfully logged in. 
post '/sign-in' do
    user = User.where(email: params[:email]).first

    if user && user.password == params[:password]
        session[:user_id] = user.id
        flash[:success] = "You have successfully logged in!"
        redirect '/feed'

    else
        flash[:error] = 'Invalid email or password'
        redirect '/'
    end
end

#click the link, signs the user out and redirects to the home page.
get '/sign_out' do 
    session[:user_id] = nil
    redirect '/'
end
#redirects the user to the delete the account page.
get '/delete_account' do
    @user = current_user
    erb :delete_account
end

#makes a post, redirects to the feed page after.
post '/blog' do 

    if params[:post][:body].length > 0
        posted_at = Time.now
        user = current_user
        Post.create(body: params[:post][:body],posted_at: posted_at, user_id: user.id)
        redirect '/feed'
    end
    
end

#makes a new user if the passwords match.makes a profile for that user as well. afterwards redirects to the home page to sign in.

post '/register' do
    if params[:user][:password] != params[:confirm_password]
        flash[:error] = "Passwords do not match!"
        redirect '/register'
        return
    end

    User.create(params[:user])
    user = User.where(fname: params[:user][:fname]).first
    Profile.create(bio: params[:profile][:bio], location: params[:profile][:location], user_id: user.id)

    redirect '/'

end

# this allows you to submit and edit your profile!
post '/edit_profile' do
    user = current_user
    user.profile.update(bio: params[:profile][:bio],location: params[:profile][:location])
    redirect '/feed'
end
# edit a post
post "/posts/:id" do
    @post = Post.find(params[:id])
    @post.update(params[:post])
    redirect "/posts/#{@post.id}"
  end
  post "/posts/:id/delete" do
    @post = Post.find(params[:id])
    @post.destroy
    redirect "/posts"
  end
#upon button click deletes the account and the profile.
post '/delete_account' do
    user = current_user
    Profile.where(user_id: user.id).destroy_all
    User.delete(user.id)
    "User delted"
end

#defintes the current user as the user signed in. used later for  all pages.
def current_user
    if session[:user_id]
        User.find(session[:user_id])
    end
end