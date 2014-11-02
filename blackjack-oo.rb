class Deck
	attr_accessor :cards

	def initialize
		@cards = []
		# Add 52 cards to deck
		['H', 'D', 'S', 'C'].each do |suit|
			['2', '3', '4', '5', '6', '7', '8', '9', 'J', 'Q', 'K', 'A'].each do |value|
				@cards << Card.new(suit, value)
			end
		end
	end

	# Shuffles the deck.
	def shuffle_deck!
		cards.shuffle!
	end

	# Removes the top card from the deck and returns it.
	def deal_one
		cards.pop
	end
end


class Card
	attr_accessor :suit, :value

	def initialize(suit, value)
		@suit = suit
		@value = value
	end

	# Translates codes 'H' to readable format, i.e. 'Heart'.
	def find_suit
		case suit
			when 'H' then 'Hearts'
			when 'D' then 'Diamonds'
			when 'S' then 'Spades'
			when 'C' then 'Clubs'
		end
	end

	def to_s
		"The #{value} of #{find_suit}"		
	end
end

module Hand
	# Displays the current hand.
	def show_hand
		puts "---- #{name}'s Hand: ----"
		cards.each do |card|
			puts "=> #{card}"
		end
		puts "=> Total value: #{total_value}"
	end

	# Calculates the total value of a hand.
	def total_value
		sum = 0
		count_of_aces = 0
		cards.each do |card|
			if ['J', 'Q', 'K'].include?(card.value)
				sum += 10
			elsif card.value == 'A'
				sum += 11
				count_of_aces += 1
			else
				sum += card.value.to_i
			end
		end
		if sum > 21 && count_of_aces >= 1
			sum = sum - 10
		end
		sum
	end

	# Deals one card and adds it to the hand.
	def add_card(new_card)
		cards << new_card
		puts "New card dealt for #{name}: #{new_card}"
	end
end

class Player
	include Hand

	attr_accessor :name, :cards

	def initialize
		@name = "Player"
		@cards = []
	end
end

class Dealer
	include Hand

	attr_accessor :name, :cards

	def initialize
		@name = "Dealer"
		@cards = []
	end
end

class Game
	attr_accessor :player, :dealer, :deck

	def initialize
		@deck = Deck.new
		@player = Player.new
		@dealer = Dealer.new
	end

	# Given a player/dealer, returns true if the player/dealer has a blackjack.
	def blackjack?(obj)
		obj.total_value == 21
	end

	# Given a player/dealer, returns true if the player/dealer has busted.
	def busted?(obj)
		obj.total_value > 21
	end

	# Both the player and the dealer gets dealt 2 cards.
	def deal_cards
		player.add_card(deck.deal_one)
		player.add_card(deck.deal_one)
		dealer.add_card(deck.deal_one)
		dealer.add_card(deck.deal_one)
	end

	# Display the current hands.
	def show_hands
		player.show_hand
		dealer.show_hand
	end

	# Check for blackjack.
	def check_for_blackjack
		if blackjack?(player)
			puts "Player has hit blackjack! You won!"
			exit
		elsif blackjack?(dealer)
			puts "Dealer has hit blackjack! You lost!"
			exit
		end
	end

	# Player's turn.
	def players_turn
		loop do
			# Asks if player wants to hit or stay.
			begin
				puts "Would you like to hit or stay? 1) Hit 2) Stay"
				choice = gets.chomp.to_i
			end until [1,2].include?(choice)
			# If player chooses to 1) Hit.
			if choice == 1
				player.add_card(deck.deal_one)
				puts "Your new total is #{player.total_value}."
				if blackjack?(player)
					puts "Player has hit blackjack! You won!"
					exit
				elsif busted?(player)
					puts "You busted! Sorry, you lost."
					exit
				else
					next
				end
			# Break loop if 2) Stay is chosen.
			else
				break
			end
		end
	end

	# Dealer's turn.
	def dealers_turn
		# Dealer keeps hitting until it reaches at least 17.
		while (dealer.total_value < 17)
			dealer.add_card(deck.deal_one)
			puts "Dealer's new total is #{dealer.total_value}."
			if blackjack?(dealer)
				puts "Dealer has hit blackjack! Sorry, you lost."
				exit
			elsif busted?(dealer)
				puts "Dealer has busted! Congrats, you won!"
				exit
			end
		end
	end

	# Compare player and dealer's hand to find the winner.
	def find_winner
		if dealer.total_value == player.total_value
			puts "It's a tie."
		elsif dealer.total_value > player.total_value
			puts "Dealer has a better hand. Sorry, you lost."
		else
			puts "You have the better hand. Yay! You won!"
		end
	end

	def play
		deck.shuffle_deck!
		deal_cards
		show_hands
		check_for_blackjack
		players_turn
		dealers_turn
		find_winner
	end
end

game = Game.new.play