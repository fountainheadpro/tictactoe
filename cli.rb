require File.join(File.dirname(__FILE__), '/tictactoe.rb')

game=TTTGame.new

def print_field(game)
  symbol_map={
      TTTGame::X => 'X',
      TTTGame::O => 'O',
      TTTGame::EMPTY => nil
  }
  field=game
    .each_with_index
    .map{|cell, index|
      symbol_map[cell] || (TTTGame::FIELD_SIZE-index)
     }
    .each_slice(3)
    .map{|row| row.join(' | ')}
    .join("\n---------\n")
  puts field
end

message='Enter the cell number to make your move.'
until game.over? do
 system 'clear'
 puts message
 print_field(game)
 begin
  game.register_player_move(TTTGame::FIELD_SIZE-gets.to_i)
  message=''
 rescue
   message=$!
 end
end

system 'clear'
puts "Game over. Result: #{game.result}"
print_field(game)