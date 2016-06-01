require 'discordrb'
require 'open-uri'
require 'json'

# Initialize bot
# Requires a Discord bot account
bot = Discordrb::Commands::CommandBot.new token: '<BOT_TOKEN>', application_id: '<APPLICATION_ID>', prefix: '$'

# Output the invite URL to the console so the bot account can be invited to the channel
# Only has to be done once
puts "This bot's invite URL is #{bot.invite_url}."
puts 'Click on it to invite it to your server.'

vote_in_progress = false
votes = []
counts = []

# **************************************************************************************
# MESSAGES

# Responds to any user that types 'Ping!' with 'Pong!'
bot.message(with_text: 'Ping!') do |event|
	event.respond 'Pong!'
end

# **************************************************************************************
# COMMANDS

# Given at least two options, randomly returns one of those options
bot.command(:decide, min_args: 2) do |event, *args|
	i = rand(0..args.length-1)
	args[i]
end

# Ends the vote and outputs the results
bot.command :end_vote do |event|
	vote_in_progress = false
	event << "Voting has ended."
	event << "Results:\n"
	for i in 0..votes.length-1
		vote = votes[i]
		count = counts[i]
		event << "#{vote}: #{count}"
	end
	nil
end

# Grabs sprite and types from Pokemon API given a certain pokemon
bot.command :pokedex do |event, pokemon|
	url = "http://pokeapi.co/api/v2/pokemon/" + pokemon
	doc = open(url, "User-Agent" => "Discord Bot").read
	response = JSON.parse(doc)

	event.respond response['sprites']['front_default']

	types = []
	response['types'].each do |type|
		types.push(type['type']['name'])
	end

	message = "Types:"

	for i in 0..types.length-1
		message = message + "\n" + types[i]
	end
	
	message
end

# Starts a vote
bot.command :start_vote do |event|
	vote_in_progress = true
	votes = []
	counts = []
	"New vote started."
end

# Adds a tally given a player's vote
bot.command :vote do |event, *args|
	return unless vote_in_progress
	vote = args.join(' ')
	i = votes.index(vote)
	if i
		counts[i] = counts[i].to_i + 1
	else
		index = votes.length
		votes[index] = vote
		counts[index] = 1
	end
	nil
end

# **************************************************************************************

bot.run
