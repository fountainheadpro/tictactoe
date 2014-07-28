require File.join(File.dirname(__FILE__),'/../tictactoe.rb')
#extending the game class to enable strategies testing
class TestableTTTGame < TTTGame

  public
  def inject_state(readable_state)
    char_map={'X'=>X,'O'=>O, '_'=>EMPTY}
    @state=EMPTY
    readable_state.gsub(/[^XO_]/, '').each_char{|c|
      @state<<=CELL_SIZE
      @state+=char_map[c]
    }
    move
  end

  def random_state
    symbols=[X, O, EMPTY]
    @state=EMPTY
    FIELD_SIZE.times{
      @state <<= CELL_SIZE
      @state += symbols.sample
    }
  end

  def last_position
    @last_position
  end

  def last_strategy
    @last_strategy
  end

end