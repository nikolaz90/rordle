class GamesController < ApplicationController
    # exclude? à trouver et answer = [include?, deep_dup]
    def index
        session[:answers] = []
        session[:rails_method] = random_rails_method.sample.to_s.upcase
        @answers = []
        @rails_method = session[:rails_method]
        @colors = Array.new(6) { Array.new(@rails_method.size) { nil } }
        @alphabet = (('A'..'Z').to_a + ['?', '_', '!']).map { |char| [char, 'gray-100'] }.to_h
    end

    def answer
        answer = params[:answer].upcase
        session[:answers] << answer if is_a_valid_answer?(answer)
        colors, alphabet = compute_colors(session[:rails_method], session[:answers])
        respond_to do |format|
            format.turbo_stream {
                render turbo_stream:
                    turbo_stream.replace(
                        'game_turbo_frame',
                        partial: 'games/game',
                        locals: {
                            rails_method: session[:rails_method],
                            answers: session[:answers],
                            colors: colors,
                            alphabet: alphabet
                        }
                    )
            }
        end
    end

    private

    def compute_colors(rails_method, answers)
        colors = Array.new(6) { Array.new(rails_method.size) { nil } }
        alphabet = (('A'..'Z').to_a + ['?', '_', '!']).map { |char| [char, 'gray-100'] }.to_h
        answers.each_with_index do |answer, answer_index|
            remaining_chars = []
            answer.chars.each_with_index do |char, char_index|
                if char == rails_method[char_index]
                    colors[answer_index][char_index] = 'green'
                    alphabet[char] = 'green-400'
                else
                    remaining_chars << rails_method[char_index]
                end
            end
            answer.chars.each_with_index do |char, char_index|
                if remaining_chars.include?(char)
                    colors[answer_index][char_index] = 'orange' unless colors[answer_index][char_index]
                    alphabet[char] = 'orange-400' unless alphabet[char] == 'green-400'
                    remaining_chars.delete_at(remaining_chars.index(char) || remaining_chars.length)
                else
                    alphabet[char] = 'slate-400' if alphabet[char] == 'gray-100'
                end
            end

        end
        [colors, alphabet]
    end

    def is_a_valid_answer?(answer)
        answer.size == session[:rails_method].size && is_existing_method?(answer)
    end

    def is_existing_method?(answer)
        random_rails_method.include?(answer)
    end

    def random_rails_method
        @methods ||= Array.public_instance_methods.grep(/[a-z_?!]+/).map { |method| method.to_s.upcase }
    end
end
