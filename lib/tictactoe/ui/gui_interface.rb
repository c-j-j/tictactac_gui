require 'tictactoe/game'
require 'qt'
require 'tictactoe/ui/gui_board_cell'

module TicTacToe
  module UI
    class GUIInterface < Qt::Widget
      attr_reader :cells
      attr_reader :status_label
      attr_reader :play_button
      attr_reader :game_choices
      attr_reader :game_sizes
      attr_reader :next_game_type_to_build
      attr_reader :next_board_size_to_build
      attr_reader :ui_grid

      INVALID_MOVE_MESSAGE = "Invalid move, try again"
      #registers functions so GUI can call them
      START_GAME_FUNCTION = "init_game()"
      PREPARE_GAME_TYPE_FUNCTION = 'prepare_next_game_type_to_create(QString)'
      PREPARE_BOARD_SIZE_FUNCTION = "prepare_board_size(QString)"
      slots START_GAME_FUNCTION
      slots PREPARE_GAME_TYPE_FUNCTION
      slots PREPARE_BOARD_SIZE_FUNCTION

      TOP_PADDING = 1

      def initialize(game = nil)
        super(nil)
        @ui_grid = Qt::GridLayout.new(self)
        @next_game_type_to_build = TicTacToe::Game.default_game_type
        @next_board_size_to_build = TicTacToe::Game.default_board_size
        @game = game
        init_board(@game.board) unless @game.nil?
        init_screen
        show
      end

      def init_screen
        setWindowTitle("Tic Tac Toe")
        resize(600, 600)
        create_widgets
        position_widgets
      end

      def board_clicked(position)
        return unless current_player_human?(@game)

        if !@game.move_valid?(position)
          print_invalid_move_message
          return
        end

        @game.add_move(position)
        update_game_display(@game)
        play_game(@game)
      end

      def init_game
        @game = create_new_game
        start_game(@game)
      end

      def start_game(game)
        init_board(game.board)
        play_game(game)
      end

      def play_game(game)
        until game.game_over? || current_player_human?(game)
          game.play_turn
          update_game_display(game)
        end
      end

      def print_outcome(game_presenter)
        update_status(game_presenter.status)
      end

      def print_invalid_move_message
        update_status(INVALID_MOVE_MESSAGE)
      end

      def print_board(board_positions)
        @cells.each_with_index do |cell, index|
          cell.text = board_positions[index]
        end
      end

      def prepare_next_game_type_to_create(game_type)
        @next_game_type_to_build = game_type
      end

      def prepare_board_size(board_size)
        @next_board_size_to_build = board_size
      end

      def init_board(board)
        clear_board
        (0...board.number_of_positions).each do |cell_index|
          cell = TicTacToe::UI::GUIBoardCell.new(self, cell_index)
          row, column = get_row_and_column_from_index(board, cell_index)
          @ui_grid.addWidget(cell, row + TOP_PADDING, column)
          @cells << cell
        end
      end

      def create_new_game
        TicTacToe::Game.build_game(@next_game_type_to_build, @next_board_size_to_build.to_i)
      end

      private

      def update_game_display(game)
        game_presenter = game.presenter
        print_board(game_presenter.board_as_array)
        update_status(game_presenter.status)
      end

      def current_player_human?(game)
        !game.current_player_is_computer?
      end

      def create_widgets
        @status_label = Qt::Label.new("Press play to begin", self)
        @play_button = Qt::PushButton.new('Play', self)
        register_button_press(@play_button, START_GAME_FUNCTION)
        @game_choices = create_game_choices_combo_box
        @game_sizes = create_game_size_combo_box
      end

      def position_widgets
        @ui_grid.addWidget(@game_choices, 0, 0)
        @ui_grid.addWidget(@game_sizes, 0, 1)
        @ui_grid.addWidget(@play_button, 0, 2)
        @ui_grid.addWidget(@status_label, 5, 0)
      end

      def clear_board
        unless @cells.nil?
          @cells.each do |cell|
            cell.hide
            @ui_grid.removeWidget(cell)
          end
        end
        @cells = []
      end

      def create_game_choices_combo_box
        create_combo_box(TicTacToe::Game::GAME_TYPES, PREPARE_GAME_TYPE_FUNCTION)
      end

      def create_game_size_combo_box
        create_combo_box(TicTacToe::Game::BOARD_SIZES, PREPARE_BOARD_SIZE_FUNCTION)
      end

      def create_combo_box(choices, select_function)
        selection_menu = Qt::ComboBox.new(self)
        choices.each {|choice| selection_menu.addItem(choice.to_s) }
        connect(selection_menu, SIGNAL("activated(QString)"), self, SLOT(select_function))
        selection_menu
      end

      def register_button_press(button, function)
        connect(button, SIGNAL(:pressed), self, SLOT(function))
      end

      def update_status(message)
        status_label.text = message
      end

      def get_row_and_column_from_index(board, cell_index)
        cell_index.divmod(board.row_size)
      end

    end
  end
end
