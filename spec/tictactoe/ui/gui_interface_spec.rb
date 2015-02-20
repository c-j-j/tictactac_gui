require 'tictactoe/board'
require 'tictactoe/stubs/stub_game'
require 'tictactoe/ui/gui_interface'
require 'ostruct'

describe TicTacToe::UI::GUIInterface do
  let(:board) { TicTacToe::Board.new(3) }
  let(:board_helper) { TicTacToe::BoardHelper.new }
  let(:position) {1}
  let(:stub_game){TicTacToe::StubGame.new}
  let(:gui_interface){TicTacToe::UI::GUIInterface.new(stub_game)}
  let(:game_presenter) { TicTacToe::GamePresenter::Builder.new
    .with_board(board).build }

  before(:all) do
    @app = Qt::Application.new(ARGV)
  end

  it 'creates board with cells' do
    gui_interface.init_board(board)
    expect(gui_interface.cells.size).to be(stub_game.number_of_positions)
  end

  it 'deletes previous board when board is subsequently initiated' do
    gui_interface.init_board(board)
    widget_count_after_first_initiation = gui_interface.ui_grid.count
    gui_interface.init_board(board)
    widget_count_after_second_initiation = gui_interface.ui_grid.count

    expect(widget_count_after_first_initiation).to eq(widget_count_after_second_initiation)
  end

  it 'propogates move to game when human clicks board' do
    stub_game.set_presenter(game_presenter)
    gui_interface.board_clicked(position)
    expect(stub_game.add_move_called?).to be true
  end

  it 'prints error message when invalid move provided' do
    stub_game.set_presenter(game_presenter)
    stub_game.all_moves_are_invalid
    gui_interface.board_clicked(position)
    expect(gui_interface.status_label.text).to include(TicTacToe::UI::GUIInterface::INVALID_MOVE_MESSAGE)
  end

  it 'populates game choices selection menu from Game object' do
    expect(gui_interface.game_choices.count).to eq(TicTacToe::Game::GAME_TYPES.size)
  end

  it 'default game to be created is first of Games types' do
    expect(gui_interface.next_game_type_to_build).to eq(TicTacToe::Game.default_game_type)
  end

  it 'populates size choices selection menu from Game' do
    expect(gui_interface.game_sizes.count).to eq(TicTacToe::Game::BOARD_SIZES.size)
  end

  it 'default board size is first option provided by Game' do
    expect(gui_interface.next_board_size_to_build).to eq(TicTacToe::Game.default_board_size)
  end

  it 'prepares selected board size to be the next board size to build' do
    gui_interface.prepare_board_size('some board size')
    expect(gui_interface.next_board_size_to_build).to eq('some board size')
  end

  it 'prepared selected game type to be the next game type to build' do
    gui_interface.prepare_next_game_type_to_create('some game type')
    expect(gui_interface.next_game_type_to_build).to eq('some game type')
  end

  it 'creates game with selected properties' do
    game = gui_interface.create_new_game
    expect(game).to be_kind_of(TicTacToe::Game)
  end

  it 'calls play turn when game is not over' do
    stub_game.play_turn_ends_game
    stub_game.set_current_player_to_computer(true)
    stub_game.set_presenter(game_presenter)
    gui_interface.start_game(stub_game)
    expect(stub_game.play_turn_called?).to be(true)
  end

  it 'does not call play turn when current player is human' do
    stub_game.set_presenter(game_presenter)
    gui_interface.start_game(stub_game)
    expect(stub_game.play_turn_called?).to be(false)
  end

  it 'prints out board when game turn is played' do
    stub_game.play_turn_ends_game
    stub_game.set_presenter(game_presenter)
    gui_interface.start_game(stub_game)
    assert_board_is_correct
  end

  it 'prints out next player turn when turn is played' do
    stub_game.play_turn_ends_game
    stub_game.set_current_player_to_computer(true)
    game_presenter.current_player_mark = 'X'
    stub_game.set_presenter(game_presenter)
    gui_interface.start_game(stub_game)
    expect(gui_interface.status_label.text).to include("X's turn")
  end

  def generate_board
    board = TicTacToe::Board.new(3)
    board_helper = TicTacToe::BoardHelper.new
    board_helper.populate_board_with_tie(board, 'X', 'O')
    board
  end

  def assert_board_is_correct
    gui_interface.cells.each_with_index do |cell, index|
      expect(cell.text).to eq(board.get_mark_at_position(index))
    end
  end
end
