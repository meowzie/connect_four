# frozen_string_literal: true

require '../lib/main.rb'
require 'pry-byebug'

describe Player do
  describe '#initialize' do
    # needs no testing
  end
end

describe Position do
  subject(:position) { described_class.new(0, 0) }
  describe '#initialize' do
    # requires no testing
  end

  describe '#update' do
    let(:carol) { double(Player, signature: 'X') }

    context 'when it is not updated' do
      it "shows '○' for position's occupier" do
        expect(position.occupier).to eq('○')
      end
    end

    context 'when it is updated' do
      before do
        allow(position).to receive(:occupied?).and_return(false)
      end

      it "shows 'X' for position's occupier" do
        position.update(carol)
        expect(position.occupier).to eq('X')
      end
    end

    context 'when it is occupied' do
      before do
        allow(position).to receive(:occupied?).and_return(true)
      end

      it 'does not update' do
        position.update(carol)
        expect(position.occupier).to eq('○')
      end
    end
  end

  describe '#occupied?' do
    context 'when it is unoccupied' do
      it 'returns false' do
        expect(position.occupied?).to be(false)
      end
    end

    context 'when it is occupied' do
      it 'returns true' do
        position.occupier = 'X'
        expect(position.occupied?).to be(true)
      end
    end
  end
end

describe Board do
  subject(:board) { described_class.new }
  before do
    board.rows = []
    6.times { board.rows << [] }
    board.rows.each { |row| 7.times { row << double(Position, occupier: '○') } }
  end

  describe '#initialize' do
    # requires no testing
  end

  describe 'full?' do
    context 'when it is full' do
      before do
        board.rows.each { |row| row.each { |position| allow(position).to receive(:occupied?).and_return(true) } }
      end

      it 'returns true' do
        expect(board.full?).to be(true)
      end
    end

    context 'when it is not full' do
      before do
        board.rows.length.times do |counter|
          board.rows[counter].each { |position| allow(position).to receive(:occupied?).and_return(true) } if counter <= 4
          board.rows[counter].each { |position| allow(position).to receive(:occupied?).and_return(false) } if counter > 4
        end
      end

      it 'returns false' do
        expect(board.full?).to be(false)
      end
    end

    context 'when it is empty' do
      before do
        board.rows.each { |row| row.each { |position| allow(position).to receive(:occupied?).and_return(false) } }
      end

      it 'returns false' do
        expect(board.full?).to be(false)
      end
    end
  end

  describe '#put' do
    # requires no testing
  end

  describe 'check_vertical' do
    context 'when connected vertically' do
      before do
        4.times { |counter| board.rows[counter + 2][0] = double(Position, occupier: 'X', row: counter + 2, column: 0) }
      end

      it 'returns true' do
        expect(board.check_vertical(board.rows[2][0])).to be(true)
      end
    end

    context 'when connected but not 4 in a row' do
      before do
        3.times { |counter| board.rows[counter + 3][0] = double(Position, occupier: 'X', row: counter + 3, column: 0) }
      end

      it 'returns false' do
        expect(board.check_vertical(board.rows[3][0])).to be(false)
      end
    end

    context 'when not 4 in a row and in the middle of the board' do
      before do
        3.times { |counter| board.rows[counter + 1][0] = double(Position, occupier: 'X', row: counter + 1, column: 0) }
      end

      it 'returns false' do
        expect(board.check_vertical(board.rows[1][0])).to be(false)
      end
    end

    context 'when 4 in a row AND in the middle of the board' do
      before do
        4.times { |counter| board.rows[counter + 1][0] = double(Position, occupier: 'X', row: counter + 1, column: 0) }
      end

      it 'returns true' do
        expect(board.check_vertical(board.rows[1][0])).to be(true)
      end
    end

    context 'when 4 in a row BUT not the same player' do
      before do
        2.times { |counter| board.rows[counter + 1][0] = double(Position, occupier: 'X', row: counter + 1, column: 0) }
        board.rows[3][0] = double(Position, occupier: 'Y', row: 2, column: 0)
        board.rows[4][0] = double(Position, occupier: 'X', row: 3, column: 0)
      end

      it 'returns false' do
        expect(board.check_vertical(board.rows[1][0])).to be(false)
      end
    end
  end

  describe 'check_horizontal' do
    context 'when connected horizontally' do
      before do
        4.times { |counter| board.rows[5][counter + 1] = double(Position, occupier: 'X', row: 5, column: counter + 1) }
      end

      it 'returns true' do
        expect(board.check_horizontal(board.rows[5][4])).to be(true)
      end
    end

    context 'when 4 in a row but ON TOP of other symbols' do
      before do
        4.times { |counter| board.rows[4][counter + 1] = double(Position, occupier: 'X', row: 4, column: counter + 1) }
        5.times do |counter|
          symbol = counter > 2 ? 'Y' : 'X'
          board.rows[5][counter + 1] = double(Position, occupier: symbol, row: 5, column: counter + 1)
        end
      end

      it 'returns true' do
        expect(board.check_horizontal(board.rows[4][2])).to be(true)
      end
    end

    context 'when connected BUT not 4 in a row' do
      before do
        3.times { |counter| board.rows[5][counter + 1] = double(Position, occupier: 'X', row: 5, column: counter + 1) }
      end

      it 'returns false' do
        expect(board.check_horizontal(board.rows[5][2])).to be(false)
      end
    end

    context 'when on the edge of the board' do
      before do
        4.times { |counter| board.rows[5][counter + 2] = double(Position, occupier: 'X', row: 5, column: counter + 2) }
      end

      it 'returns true' do
        expect(board.check_horizontal(board.rows[5][3])).to be(true)
      end
    end

    context 'when incomplete on the edge of the board' do
      before do
        3.times { |counter| board.rows[5][counter + 3] = double(Position, occupier: 'X', row: 5, column: counter + 3) }
      end

      it 'returns false' do
        expect(board.check_horizontal(board.rows[5][4])).to be(false)
      end
    end
  end

  describe 'check diagonal' do
    context 'when there is a diagonal connection with positive slope' do
      before do
        4.times { |counter| board.rows[5 - counter][0 + counter] = double(Position, occupier: 'X', row: 5 - counter, column: 0 + counter) }
      end

      it 'returns true' do
        expect(board.check_diagonal(board.rows[2][3])).to be(true)
      end
    end

    context 'when there is a diagonal connection with negative slope' do
      before do
        4.times { |counter| board.rows[5 - counter][6 - counter] = double(Position, occupier: 'X', row: 5 - counter, column: 6 - counter) }
      end

      it 'returns true' do
        expect(board.check_diagonal(board.rows[2][3])).to be(true)
      end
    end

    context 'when final is on top right' do
      before do
        4.times { |counter| board.rows[0 + counter][0 + counter] = double(Position, occupier: 'X', row: 0 + counter, column: 0 + counter) }
      end

      it 'returns true' do
        expect(board.check_diagonal(board.rows[0][0])).to be(true)
      end
    end

    context 'when final is on top left' do
      before do
        4.times { |counter| board.rows[0 + counter][6 - counter] = double(Position, occupier: 'X', row: 0 + counter, column: 6 - counter) }
      end

      it 'returns true' do
        expect(board.check_diagonal(board.rows[0][6])).to be(true)
      end
    end

    context 'not 4 in a row' do
      before do
        3.times { |counter| board.rows[0 + counter][6 - counter] = double(Position, occupier: 'X', row: 0 + counter, column: 6 - counter) }
      end

      it 'returns false' do
        expect(board.check_diagonal(board.rows[0][6])).to be(false)
      end
    end

    context 'when final is in the middle' do
      before do
        4.times { |counter| board.rows[5 - counter][0 + counter] = double(Position, occupier: 'X', row: 5 - counter, column: 0 + counter) }
      end

      it 'returns true' do
        expect(board.check_diagonal(board.rows[4][1])).to be(true)
      end
    end
  end
end

describe Game do
  subject(:game) { described_class.new }

  describe '#initialize' do
    # requires no testing
  end

  describe '#nums?' do
    context 'when both strings are numbers' do
      it 'returns true' do
        expect(game.nums?('3', '2')).to be(true)
      end
    end

    context 'when one string is a number' do
      it 'returns false' do
        expect(game.nums?('3', 'a')).to be(false)
      end
    end

    context 'when neither string is a number' do
      it 'returns false' do
        expect(game.nums?('a', 'b')).to be(false)
      end
    end
  end

  describe '#valid?' do
    context 'when valid' do
      let(:choice) { '32' }
      before do
        allow(game).to receive(:nums?).and_return(true)
      end

      it 'returns true' do
        expect(game.valid?(choice)).to be(true)
      end
    end

    context 'when longer than 3 nums' do
      it 'returns false' do
        expect(game.valid?('333')).to be(false)
      end
    end

    context 'when row is too big' do
      it 'returns false' do
        expect(game.valid?('63')).to be(false)
      end
    end

    context 'when column is too big' do
      it 'returns false' do
        expect(game.valid?('37')).to be(false)
      end
    end

    context 'when nums? is falsey' do
      before do
        allow(game).to receive(:nums?).and_return(false)
      end

      it 'returns false' do
        expect(game.valid?('6a')).to be(false)
      end
    end
  end

  describe '#choose' do
    context 'when right the first time' do
      let(:choice) { '33' }

      before do
        allow(game).to receive(:gets).and_return(choice)
      end

      it 'returns an array with coordinates' do
        expect(game.choose).to eql([3, 3])
      end
    end

    context 'when invalid' do
      let(:first) { '3a' }
      let(:second) { '33' }

      before do
        allow(game).to receive(:gets).and_return(first, second)
        allow(game).to receive(:puts)
      end

      it 'prints error message' do
        expect(game).to receive(:puts).with('Invalid input')
        game.choose
      end
    end
  end
end
