#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony' 
require 'sqlite3'


def is_barber_exsists? db, name
	db.execute('select * from Barbers where name=?', [name]).length > 0 
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exsists? db, barber
			db.execute 'insert into Barbers (name) values (?)', [barber]
		end
	end
end

def get_db 
	return SQLite3::Database.new 'barbershop.db'
end

before do
	db = get_db
	db.results_as_hash = true
	@barbers = db.execute 'select * from Barbers'
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS 
		Users (
			id        INTEGER PRIMARY KEY AUTOINCREMENT,
			username  TEXT,
			phone     TEXT,
			barber    TEXT,
			color     TEXT,
			datestamp TEXT
		)'

	db.execute 'CREATE TABLE IF NOT EXISTS
		Barbers (
			id        INTEGER PRIMARY KEY,
			name  	  TEXT
		)'
	
	seed_db db, ['Оля', 'Марк', 'Яна', 'Вася']
end

get '/' do
	erb "<h2>Добро пожаловать в Barber Shop</h2>"			
end

get '/about' do
	erb :about 
end 

get '/visit' do 
	erb :visit
end 

get '/contacts' do 
	erb :contacts 
end 

get '/showusers' do
	db = get_db
	db.results_as_hash = true
	@results = db.execute 'select * from Users order by id desc'

	erb :showusers
end

post '/visit' do
	@username      = params[:username] 
	@phone	       = params[:phone]
	@datetime      = params[:datetime]
	@barber        = params[:pick_a_barber]
	@color 		   = params[:colorpicker]
	
	hh = { :username => 'Введите имя',
		   :phone => 'Введите номер телефона',
		   :datetime => 'Введите дату и время' }

	# Первый вариант валидации
	#hh.each do |key, value|
	#	if params[key] == ''
	#		@error = hh[key]
	#		return erb :visit
	#	end
	#end

	#Второй вариант валидации
	@error = hh.select {|key, _| params[key] == ""}.values.join(", ")
	
	if @error != ''
		return erb :visit
	end

	#f = File.open './public/users.txt', 'a'
    #f.write "Клиент: #{@username}, Контакт: #{@phone}, Время и дата: #{@datetime}, Парикмахер: #{@pick_a_barber}, Цвет: #{@color}\n"
    #f.close

	db = get_db
	db.execute 'insert into 
		Users
		(
			username,
			phone,
			barber,
			color, 
			datestamp
		) 
		values (?, ?, ?, ?, ?)', [@username, @phone, @barber, @color, @datetime] 

	#erb :visit
	erb "<h3>Спасибо, вы записались</h3>"
end 

post '/contacts' do 
	@name 	 = params[:name]
	@mail 	 = params[:mail]
	@message = params[:message]

	Pony.mail(
      :from => @name + "<" + @mail + ">",
      :to => 'bukreewitaliy@gmail.com',
      :subject => @name + " от барбершопа",
      :body => @message,
      :via => :smtp,
      :via_options => { 
        :address              => 'smtp.gmail.com', 
        :port                 => '587', 
        :user_name            => 'bukreewitaliy@gmail.com', 
        :password             => 'pvot vuwj cdvw plbo', 
        :authentication       => :plain, 
        :domain               => 'localhost.localdomain'
      })
	
	# Валидация
	aa = { :name => 'Введите имя',
		   :mail => 'Введите свою почту',
		   :message => 'Введите сообщение' }
	
	@error = aa.select {|key, _| params[key] == ""}.values.join(", ")
	
	if @error != ''
		return erb :contacts
	end

	erb :contacts
end
