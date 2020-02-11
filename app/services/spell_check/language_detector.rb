# frozen_string_literal: true
module SpellCheck
  module LanguageDetector
    class << self
      def cld3
        @cld3 ||= CLD3::NNetLanguageIdentifier.new(0, 1000)
      end

      def dictionary_for_text(text)
        dictionary_for_code(code_for_text(text))
      end

      def dictionary_for_code(code)
        FFI::Hunspell.dict(code)
      end

      def code_for_text(text)
        struct = self.cld3.find_language(text)

        if struct.nil?
          return "en-US"
        end

        code = case struct.language
          when :en
            fewest_mispellings(text, %w[en-CA en-US en-GB])
          when :pt
            fewest_mispellings(text, %w[pt pt-BR])
          when :de, :es, :fr, :ko
            struct.language.to_s
          end

        code
      end

      def fewest_mispellings(text, candidate_languages)
        words = BlobProcessor.new(text).words
        scores = candidate_languages.map do |language|
          dict = FFI::Hunspell.dict(language)
          words.count { |word| dict.check?(word) }
        end

        _max_score, max_index = scores.each_with_index.max
        candidate_languages[max_index]
      end
    end
  end
end
