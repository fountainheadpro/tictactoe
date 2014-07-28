module StateSupport


  include Enumerable

  #game state is stored as 9 cells
  #each cell can be in one of three states: EMPTY, X or O.
  #so we need two bits to represent a state.
  #The whole state of the game requires 9 cell or 18 bits.
  #So it is stored as an integer.
  EMPTY=0 #00
  X=1     #01
  O=2     #10
  EMPTY_CHECK_MASK=3 #11 - used to check if certain position is empty
  CELL_SIZE=2 #two bits to store a cell

  SIZE=3
  FIELD_SIZE=SIZE*SIZE

  COMPUTER_SYMBOL=X
  PLAYER_SYMBOL=O

  def register_move(symbol, position)
    @last_position=position
    @number_of_steps+=1
    @state |= (symbol << (position*CELL_SIZE))
  end

  def self.mask_position(position)
    EMPTY_CHECK_MASK<<(position*CELL_SIZE)
  end

  def each
     if block_given?
       yieldable=@state
       FIELD_SIZE.times{
         yield(yieldable & EMPTY_CHECK_MASK)
         yieldable>>=CELL_SIZE
       }
     end
  end

end