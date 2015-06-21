require 'yaml'

class Hangman
  attr_writer :game_over, :play_desire

  def initialize
    @game_over = false
    @play_desire = true
    puts 'Initializing your game of Hangman...'
  end

  def select_a_word
    array = []
    f = File.open('5desk.txt', 'r')
    f.each_line do |line|
      if line.length > 5 && line.length < 12
        array << line
      end
    end
    return array[rand(array.length - 1)].downcase
  end

  def create_blanks word
    '_ ' * word.length
  end

  def continue?
    valid_answer = false
    until valid_answer do
      puts 'Would you like to A) continue playing or B) save your game and quit?'
      answer = gets.chomp!.downcase
      if answer == 'a'
        valid_answer = true
        return true
      elsif answer == 'b'
        valid_answer == true
        return false
      else
        puts 'Please enter a valid answer (A or B).'
      end
    end
  end

  def get_guess word, guessed_letters
    input_valid = false
    until input_valid == true 
      puts 'Enter a letter:'
      guess = gets.chomp!.downcase
      if guess =~ /[^a-zA-Z]/ || guess.length > 1
        puts 'Please enter a single, valid, letter'
      elsif guessed_letters.include? guess
        puts 'You have already guessed that letter. Guess again.'
      elsif word.include? guess
        puts 'Correct! Good guess.'
        input_valid = true
      else
        puts 'Nope!'
        input_valid = true
      end
    end
    guess
  end

  def fill_in_blanks letter, blanks, word
    blank_array = blanks.split(' ')
    word_array = word.split('')
    i = 0
    while i < word.length 
      blank_array[i] = (word_array[i] == letter) ? letter : blank_array[i]
      i += 1
    end
    blank_array.join(' ')
  end

  def win? blanks
    if !blanks.include? '_'
      puts 'You win! Congratulations!'
      game_over = true
    else
      game_over = false
    end
  end

  def lose? guesses
    lost = false
    if guesses <= 0
      puts 'You have used up all your guesses! Better luck next time.'
      lost = true
    else
      lost = false
    end
  end

  def still_want_to_play? word
    valid_answer = false
    desire = false
    print "The word was #{word}."
    until valid_answer
      puts 'Do you still want to play? Yes or No'
      answer = gets.chomp!.downcase
      if answer == 'yes'
        valid_answer = true
        desire = true
      elsif answer == 'no'
        valid_answer = true
      else
        puts 'Please enter a valid answer!'
      end
    end
    desire
  end

  def save_game(word, blanks, guesses, guessed_letters)
    save = {}
    save[:word] = word
    save[:blanks] = blanks
    save[:guesses] = guesses
    save[:guessed_letters] = guessed_letters

    File.open('save_file.txt', 'w') do |out| 
      YAML.dump(save, out)
    end
  end

  def load_game
    valid_answer = false
    until valid_answer
      puts 'Would you like to load an existing game? Yes or No.'
      answer = gets.chomp!.downcase
      if answer == 'yes'
        save = YAML.load_file('save_file.txt')
        valid_answer = true
      elsif answer == 'no'
        save = false
        valid_answer = true
      else
        puts 'Please enter Yes or No'
      end
    end
    save
  end

  def run
    game_file = load_game
    if game_file 
      save = game_file
      word = save[:word]
      blanks = save[:blanks]
      guesses = save[:guesses]
      guessed_letters = save[:guessed_letters]
    else
      word = select_a_word.strip
      blanks = create_blanks(word)
      guesses = 5
      guessed_letters = []
    end

    game_over = false
    play_desire = true

    while play_desire do
      game_over = false
      until game_over do
        if continue?
          puts "The word currently looks like #{blanks}."
          puts "Guesses left: #{guesses}."
          puts "Guessed words: #{guessed_letters}"

          letter = get_guess(word, guessed_letters)
          guessed_letters << letter
          guessed_letters.sort!

          if word.include? letter
            blanks = fill_in_blanks(letter, blanks, word)
            if win?(blanks) ? true : false
              game_over = true
              still_want_to_play? word
            end
          else
            guesses -= 1
            if lose?(guesses) ? true : false
              game_over = true
              still_want_to_play? word
            end
          end
        else
          save_file = save_game(word, blanks, guesses, guessed_letters)
          game_over = true
          play_desire = false
        end
      end
    end
  end
end

game = Hangman.new
game.run