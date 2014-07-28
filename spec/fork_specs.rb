require 'spec_helper.rb'

describe 'blocking in Tic Tac Toe game' do

  before :all do
    @game=TestableTTTGame.new
  end

  def check_state(state, position)
    @game.inject_state(state)
    @game.last_strategy.should eq(:fork)
    @game.last_position.should eq(position)
  end

  it 'identifies fork between column and row' do
    check_state(
    %q{XO_
       _X_
       _XO},5)
  end

  it 'identifies fork between row and left diagonal' do
    check_state(
    %q{_X_
       OXO
       _O_}, 8)
  end

  it 'identifies fork between left diagonal and column' do
    check_state(
    %q{___
       XXO
       _O_}, 8)
  end

  it 'identifies fork between right diagonal and column' do
    check_state(
    %q{_OX
       X_O
       _XO}, 2)
  end


end