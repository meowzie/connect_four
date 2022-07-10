# frozen_string_literal: true

require 'pry-byebug'
require 'colorize'

# methods to update and retrieve information about the positions on the Connect 4 board
class Position
  attr_accessor :occupier, :row, :column

  def initialize(row, column)
    @row = row
    @column = column
    @occupier = '○'
  end

  def update(player)
    @occupier = player.symbol unless occupied?
  end

  def occupied?
    @occupier != '○'
  end
end

# Meant to assign an identifiable user to each player
class Player
  attr_accessor :symbol, :color

  def initialize(symbol, color)
    @symbol = symbol
    @color = color
  end
end

# stores the board, the positions, and has methods to check whether or not a game was won
class Board
  attr_accessor :rows

  def initialize
    @rows = []
    6.times { @rows << [] }
    @rows.each_with_index { |row, index| 7.times { |column| row << Position.new(index, column) } }
  end

  def full?
    @rows.all? { |row| row.all?(&:occupied?) }
  end

  def put
    board = String.new('')

    @rows.each do |row|
      row.each { |position| board << "#{position.occupier} " }
      board << "\n"
    end

    puts board
  end

  def check_vertical(position, count = 0)
    final = position.row == 5
    return false if final && count != 3

    return true if count == 3

    beneath = @rows[position.row + 1][position.column]
    return false if beneath.occupier != position.occupier

    check_vertical(beneath, count + 1)
  end

  def count(position, delta_x, delta_y, count = 0)
    row = @rows[position.row + delta_y]
    return count if row.nil?

    incoming = row[position.column + delta_x]
    return count if incoming.nil? || incoming.occupier != position.occupier

    count(incoming, delta_x, delta_y, count + 1)
  end

  def check_horizontal(position)
    right = count(position, 1, 0)
    left = count(position, -1, 0)

    total = right + left + 1

    total >= 4
  end

  def check_positive_diagonal(position)
    upper_right = count(position, 1, -1)
    lower_left = count(position, -1, 1)

    total = upper_right + lower_left + 1

    total >= 4
  end

  def check_negative_diagonal(position)
    upper_left = count(position, -1, -1)
    lower_right = count(position, 1, 1)

    total = upper_left + lower_right + 1

    total >= 4
  end

  def check_diagonal(position)
    return true if check_positive_diagonal(position)

    check_negative_diagonal(position)
  end
end

# Creates a full game
class Game
  def initialize
    @player1 = Player.new('●'.red, 'RED')
    @player2 = Player.new('●'.green, 'GREEN')
    @board = Board.new
    @last_move = nil
    @current = nil
  end

  def turn(counter)
    @current = (counter % 2).zero? ? @player1 : @player2
    put(@current)
    coordinates = choose
    @last_move = @board.rows[coordinates[0]][coordinates[1]]
    @last_move.update(@current)
  end

  def play
    put_instructions
    counter = 0
    turn(counter)
    until won?(@last_move) || @board.full?
      counter += 1
      turn(counter)
    end

    end_game
  end

  def end_game
    puts "\n"
    return puts "It's a tie" if @board.full?

    @board.put

    puts @current.color == 'RED' ? "\nPLAYER #{@current.color} HAS WON!".red : "\nPLAYER #{@current.color} HAS WON!".green 
  end

  def won?(position)
    @board.check_diagonal(position) || @board.check_horizontal(position) || @board.check_vertical(position)
  end

  def put(player)
    string = "\n#{player.color}'s turn"
    puts player.color == 'RED' ? string.red : string.green
    @board.put
  end

  def put_instructions
    puts <<~HEREDOC
    
      To choose a position, type the number of the row followed by the number of the column.
      Ex: to choose the bottom left position, enter '50'. For the bottom right, enter '56', and
      for the top left, enter '00'
    HEREDOC
  end

  def nums?(row, column)
    row_num_confirm = row.to_i.to_s == row
    column_num_confirm = column.to_i.to_s == column

    row_num_confirm && column_num_confirm ? true : false
  end

  def valid?(choice)
    row = choice[0]
    column = choice[1]

    return false if @board.rows[row.to_i][column.to_i].occupied?
    return false unless choice.length == 2 && nums?(row, column)
    return false if row.to_i > 5
    return false if column.to_i > 6

    true
  end

  def choose
    choice = gets.chomp
    until valid?(choice)
      puts 'Invalid input'
      choice = gets.chomp
    end
    choice.split('').map(&:to_i)
  end
end

game = Game.new
game.play
