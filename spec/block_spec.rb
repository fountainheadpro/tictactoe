require 'spec_helper'

describe 'blocking in Tic Tac Toe game' do

  before :all do
    @game=TestableTTTGame.new
  end

  def check_state(state, position)
    @game.inject_state(state)
    @game.last_strategy.should eq(:block)
    @game.last_position.should eq(position)
  end

  it 'Blocks if there are two player symbols in a row' do
    check_state(
    %q{O__
       XXO
       O_O},1)
  end

  it 'Blocks if there are two player symbols in a column' do
    check_state(
    %q{_X_
       XOO
       OXO},6)
  end

  it 'Blocks if there are two player symbols on left diagonal' do
    check_state(
    %q{O_X
       X_O
       OXO},4)
  end

  it 'Blocks if there are two player symbols on right diagonal' do
    check_state(
    %q{X_O
       _OX
       _XO},2)
  end

end

