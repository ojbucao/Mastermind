#! /usr/bin/ruby

# Mastermind Game by Orlando Bucao SEP2014

class String
  def black;   "\033[30m#{self}\033[0m" end
  def red;     "\033[31m#{self}\033[0m" end
  def green;   "\033[32m#{self}\033[0m" end
  def brown;   "\033[33m#{self}\033[0m" end
  def orange;  "\033[91m#{self}\033[0m" end
  def blue;    "\033[34m#{self}\033[0m" end
  def magenta; "\033[35m#{self}\033[0m" end
end

class Board
  attr_reader :secret_code

  VALID_COLORS = 'ROYGBV'.split(//)

  def initialize
    @secret_code = (0...4).map { VALID_COLORS[rand(6)] }
  end

  def display_guess(guess, num)
    print sprintf('%02d', num + 1) + " | "
    guess.code.each_with_index do |value|
      print "#{map_color(value)}  "
    end
    print "| "
  end

  def display_secret_code
    puts "====================="
    print "     "
    @secret_code.each do |letter|
      print "#{map_color(letter)}  "
    end
    puts
    puts
  end

  def rate_guess(guess)
    sc = @secret_code.clone
    gc = guess.code.clone

    # detect correct color, correct location
    4.times do |x|
      if sc[x] == gc[x]
        guess.rating << "+"
        sc[x] = nil
        gc[x] = nil
      end
    end

    # detect correct color, wrong location
    4.times do |i|
      next if guess.code.nil?
      4.times do |j|
        if !sc[j].nil? && sc[j] == gc[i]
          guess.rating << "-"
          sc[j] = nil
          break
        end
      end
    end
  end

  def display_rating(guess)
    print guess.rating.join('')
    puts
  end

  def map_color(letter)
    # return colored circle for letter
    case letter
      when 'R' then "\u2b24".red
      when 'O' then "\u2b24".orange
      when 'Y' then "\u2b24".brown
      when 'G' then "\u2b24".green
      when 'B' then "\u2b24".blue
      when 'V' then "\u2b24".magenta
    end
  end
end

class Player
  attr_accessor :guess

  def initialize
    @guess = Guess.new
  end
end

class Guess
  attr_accessor :code, :rating

  def initialize
    @code = []
    @rating = []
  end

  def valid?
    result = true
    result = false if @code.size != 4
    @code.each do |x|
      result = false unless Board::VALID_COLORS.include? x
    end
    result
  end

  def clear
    @code.clear
    @rating.clear
  end
end

class Game
  def play
    board = Board.new
    player = Player.new

    print_instructions()

    12.times do |num|
      get_guess(player)
      board.rate_guess(player.guess)
      board.display_guess(player.guess, num)
      board.display_rating(player.guess)
      break if player.guess.rating == ["+","+","+","+"]
    end

    board.display_secret_code
  end

  def get_guess(player)
    player.guess.clear
    until player.guess.valid? do
      print "   > "
      player.guess.code = gets.chomp.upcase.split(//)
    end
  end

  def print_instructions
    puts "\nWelcome to MasterMind!"
    puts "A secret code of 4 colors has been generated."
    puts "Valid colors are R,O,Y,G,B,V."
    puts "You have 12 chances to guess what it is."
    puts "(+) means a correct color at the correct spot."
    puts "(-) means a correct color at the wrong spot."
    puts "Enter your guess. (example: yorg)"
  end
end


game = Game.new
continue = true
while continue do
  game.play

  answer = ""
  until ['y','n'].include? answer do
    print("Play again? (y or n) > ")
    answer = gets.chomp.downcase
  end
  continue = false if answer == 'n'
end
puts "Bye."