class TTTGame

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

  COMPUTER_SYMBOL=X
  PLAYER_SYMBOL=O

  SIZE=3
  FIELD_SIZE=SIZE*SIZE
  CENTER = FIELD_SIZE/2
  CORNERS= [0,2,6,8]
  SIDES  = [1,3,4,7]
  DIAGS  = [[0,4,8],[6,4,2]]

  INDEXERS={
      row:  (0..2),
      col:  (0..2),
      diag: (0..1)
  }

  #buiding patterns to select rows, columns or diagonals with single element selected
  SINGLE_PATTERNS=[X,O, EMPTY_CHECK_MASK].inject({}){|res, symbol|
      res[symbol]={
        row:   [symbol, (symbol<<CELL_SIZE), (symbol<<CELL_SIZE*2)], #__X, _X_, X__ or __O, _O_, O__
        col:   [symbol, symbol<<(SIZE*CELL_SIZE), symbol<<2*SIZE*CELL_SIZE], #same for columns
        diag1: [symbol, (symbol<<(SIZE+1)*CELL_SIZE), (symbol<<2*(SIZE+1)*CELL_SIZE)], #same for first diagonal
        diag2: [symbol<<(SIZE-1)*CELL_SIZE, (symbol<<(SIZE+1)*CELL_SIZE), (symbol<<2*SIZE*CELL_SIZE)] #same for second diagonal
    }
    res
  }

  #selectors help select rows, columns and diagonals
  SELECTORS=SINGLE_PATTERNS[EMPTY_CHECK_MASK].map{|key,patterns|
   {key=>patterns.reduce(:|)}
  }.reduce(:merge)

  #Masks to select every row, column, diagonal
  ALL_SELECTORS={
    row: INDEXERS[:row].map{|row_num| SELECTORS[:row]<<row_num*SIZE*CELL_SIZE},
    col: INDEXERS[:col].map{|col_num| SELECTORS[:col]<<col_num*CELL_SIZE},
    diag: [SELECTORS[:diag1],SELECTORS[:diag2]]
  }

  #  XX_ or _XX or X_X for ech row, column and diagonal
  # formed by combining singles.
  WINNABLE_PATTERNS=SINGLE_PATTERNS.map{|symbol,pattern_set|
    {symbol=>pattern_set.map{|key, patterns|
      {key=>patterns.combination(2).map{|a,b| a|b}.sort_by{|s| -s}} #two elements on a row, column or diagonals are winnable
    }.reduce(:merge)}
  }.reduce(:merge)

  ALL_SINGLE_PATTERNS=Hash.new{|hash, symbol|
    hash[symbol]={
        row: INDEXERS[:row].map{|row_num| SINGLE_PATTERNS[symbol][:row].map{|pattern| pattern<<row_num*SIZE*CELL_SIZE}},
        col: INDEXERS[:col].map{|col_num| SINGLE_PATTERNS[symbol][:col].map{|pattern|  pattern<<col_num*CELL_SIZE}},
        diag: [SINGLE_PATTERNS[symbol][:diag1], SINGLE_PATTERNS[symbol][:diag2]]
    }
  }

  ALL_WINNABLE_PATTERNS=Hash.new{|hash, symbol|
      hash[symbol]={
          row: INDEXERS[:row].map{|row_num| WINNABLE_PATTERNS[symbol][:row].map{|pattern|  pattern<<row_num*SIZE*CELL_SIZE}},
          col: INDEXERS[:col].map{|col_num| WINNABLE_PATTERNS[symbol][:col].map{|pattern|  pattern<<col_num*CELL_SIZE}},
          diag: [WINNABLE_PATTERNS[symbol][:diag1], WINNABLE_PATTERNS[symbol][:diag2]]
      }
  }

  MOVE_VALIDATION_CHECKS=[
      {
        check: -> position, state {position.between?(0,FIELD_SIZE-1)},
        message: 'Invalid Position. Please enter number between 1 and 9.'
      },
      {
        check: -> position, state {
          p position
          mask=EMPTY_CHECK_MASK<<(position*CELL_SIZE)
          (state & mask)==0
        },
        message: 'This position is taken.'
      }
  ]

  def initialize
    @state=EMPTY
    @number_of_steps=0
    move
  end

  private
  def self.find_winnable_for(symbol, selector, state)
    mask_set=ALL_WINNABLE_PATTERNS[symbol][selector]
    selectors=ALL_SELECTORS[selector]
    position=nil
    selector_index=mask_set.zip(selectors).find_index{|masks, selector_mask|
      position=masks.find_index{|mask| state & selector_mask==mask}
    }
    position_resolvers={
      row:  -> p,i {SIZE*i+p},
      col:  -> p,i {SIZE*p+i},
      diag: -> p,i {[(SIZE+1)*p, (SIZE-1)*(p+1)][i]}
    }
    position_resolvers[selector].call(position, selector_index) if selector_index && position
  end

  def self.find_winnable(symbol, state)
    find_winnable_for(symbol, :row, state) ||
    find_winnable_for(symbol, :col, state) ||
    find_winnable_for(symbol, :diag, state)
  end

  #fork is crossing of two singles row or col or diag
  def self.find_fork_for(symbol, slice1, slice2, state)
    permutations=INDEXERS[slice1].to_a.product(INDEXERS[slice2].to_a)
    singles_set1=ALL_SINGLE_PATTERNS[symbol][slice1]
    singles_set2=ALL_SINGLE_PATTERNS[symbol][slice2]
    selector_set1=ALL_SELECTORS[slice1]
    selector_set2=ALL_SELECTORS[slice2]
    pos1,pos2=permutations.find{|slice1_index, slice2_index|
      selected_slice1 = state & selector_set1[slice1_index]
      selected_slice2 = state & selector_set2[slice2_index]
      pattern1=singles_set1[slice1_index].find{|pattern| pattern==selected_slice1} # find single of first slice
      pattern2=singles_set2[slice2_index].find{|pattern| pattern==selected_slice2} # find single on second slice
      ((pattern1 && pattern2).to_i>0) &&              # found both singles
      (pattern1!=pattern2)                            # they are not the same
    }
     unless pos1.nil?
       slice2==:diag ? DIAGS[pos2][pos1] : pos1*SIZE+pos2
     end
  end

  def self.find_fork(symbol, state)
    find_fork_for(symbol, :row, :col, state)  ||
    find_fork_for(symbol, :row, :diag, state) ||
    find_fork_for(symbol, :col, :diag, state)
  end

  def valid_move?(position)
    MOVE_VALIDATION_CHECKS.each{|check|
      raise check[:message].to_s unless check[:check].call(position, @state)
    }
  end

  #game strategies are shamelessly stolen from http://en.wikipedia.org/wiki/Tic-tac-toe
  STRATEGIES={
    win: -> state {
      find_winnable(COMPUTER_SYMBOL, state)
    },
    block: -> state {
      find_winnable(PLAYER_SYMBOL, state)
    },
    fork:-> state {
      find_fork(COMPUTER_SYMBOL,state)
    },
    block_fork: -> state {
      find_fork(PLAYER_SYMBOL,state)
    },
    center: -> state {
      state & (EMPTY_CHECK_MASK << (CENTER*CELL_SIZE))==0 ? CENTER : nil
    },
    opposite_corner: -> state {
      CORNERS.find{|opposite_corner|
        corner=FIELD_SIZE-1-opposite_corner
        (state & EMPTY_CHECK_MASK<<(opposite_corner*CELL_SIZE))==0 && (state & PLAYER_SYMBOL<<(corner*CELL_SIZE))>0
      }
    },
    empty_corner: -> state{
      CORNERS.find{|corner| state & EMPTY_CHECK_MASK<<(corner*CELL_SIZE)==0}
    },
    empty_side:-> state {
      SIDES.find{|side| state & EMPTY_CHECK_MASK<<(side*CELL_SIZE)==0}
    }
  }

  def register_move(symbol, position)
    @last_position=position
    @number_of_steps+=1
    @state |= (symbol << (position*CELL_SIZE))
  end

  def move
    position=nil
    STRATEGIES.find{|key, strategy|
      @last_strategy=key
      position = strategy.call(@state)
    }
    register_move(COMPUTER_SYMBOL, position)
  end

  public
  def register_player_move(position)
    register_move(PLAYER_SYMBOL, position) if valid_move?(position)
    move
  end

  def won?
    @last_strategy==:win
  end

  def over?
    @number_of_steps==FIELD_SIZE || won?
  end

  def result
    won? ? :computer_won : over? ? :tie : nil
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


