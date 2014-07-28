require File.join(File.dirname(__FILE__), '/state_support.rb')
require File.join(File.dirname(__FILE__), '/computer_play_support.rb')
require File.join(File.dirname(__FILE__), '/player_support.rb')

class TTTGame

  include StateSupport
  include ComputerPlaySupport
  include PlayerSupport

  def initialize
    @state=EMPTY
    @number_of_steps=0
    computer_move
  end

  public
  def won?
    @last_strategy==:win
  end

  def over?
    @number_of_steps==FIELD_SIZE || won?
  end

  def result
    won? ? :computer_won : over? ? :tie : nil
  end

  def move(position)
    player_move(position)
    computer_move
  end


end


