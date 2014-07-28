require 'spec_helper.rb'

describe 'winning Tic Tac Toe game' do

  before :all do
    @game=TestableTTTGame.new
  end

  def check_state(state, position)
    @game.inject_state(state)
    @game.result.should eq(:computer_won)
    @game.last_position.should eq(position)
  end

  it 'Wins the game if there are two unblocked XX on a row' do
    check_state(
    %q{XX_
       OO_
      _XO},6)
  end

  it 'Wins the game if there are two unblocked XX on a column' do
    check_state(
    %q{X__
       XO_
       _XO},2)
  end

  it 'Wins the game if there are two unblocked XX on left diagonal' do
    check_state(
    %q{X_O
       XXO
       O__}, 0)
  end

  it 'Wins the game if there are two unblocked XX on right diagonal' do
    check_state(
    %q{O_X
       XXO
       __O}, 2)
  end

end