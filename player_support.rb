module PlayerSupport

  include StateSupport

  MOVE_VALIDATION_CHECKS=[
      {
        check: -> position, state {position.between?(0,FIELD_SIZE-1)},
        message: 'Invalid Position. Please enter number between 1 and 9.'
      },
      {
        check: -> position, state {
          mask=StateSupport::mask_position(position)
          (state & mask)==0
        },
        message: 'This position is taken.'
      }
  ]

  def validate(position)
    MOVE_VALIDATION_CHECKS.each{|check|
      raise check[:message].to_s unless check[:check].call(position, @state)
    }
  end

  public
  def player_move(position)
    validate(position)
    register_move(PLAYER_SYMBOL, position)
  end


end