# frozen_string_literal: true
require "uri"

class SpellCheck::BlobProcessor
  LTRIM = /^[^\p{Letter}\p{Number}]*/i.freeze
  LETTERS_ONLY = /^(\p{Letter}*[.'’@-]*\p{Number}*)*/i.freeze
  DIGITS = /^\d+$/.freeze
  SLASH = %r{/}.freeze
  TRAILING_PERIOD = /(?<!\.)\.$/.freeze
  TRAILING_APOSTRPOHE = /’|'$/.freeze

  EMAIL =

    def initialize(text)
      @text = text
    end

  def words
    normalized_word_details.keys
  end

  def normalized_word_details
    @normalized_word_details ||= @text
      .split(/\s+/)
      .map { |word| normalize_word(word) }
      .reject(&:empty?)
      .reject { |word| word.ends_with?("...") }
      .reject { |word| word.match(URI::DEFAULT_PARSER.make_regexp) || word.match(URI::MailTo::EMAIL_REGEXP) }
      .group_by { |word| word }
      .transform_values(&:count)
  end

  def normalize_word(word)
    word.gsub!(LTRIM, "")

    word = if (match = LETTERS_ONLY.match(word))
        match[0]
      else
        ""
      end

    word.gsub!(DIGITS, "")
    word.gsub!(SLASH, " ")
    word.gsub!(TRAILING_PERIOD, "")
    word.gsub!(TRAILING_APOSTRPOHE, "")
    word
  end
end
