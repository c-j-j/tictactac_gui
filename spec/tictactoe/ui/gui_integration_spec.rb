$:<< File.join(File.dirname(__FILE__), '../lib')

require 'tictactoe/ui/gui_interface'

describe "Integration Test for GUI" do
  it "plays CVC on GUI" do
      interface = TicTacToe::UI::GUIInterface.new
      interface.init_game
  end
end
