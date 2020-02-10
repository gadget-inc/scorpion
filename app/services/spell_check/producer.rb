# frozen_string_literal: true
require "set"

module SpellCheck
  class Producer
    include SemanticLogger::Loggable

    attr_reader :crawl_attempt

    def initialize(crawl_attempt)
      @crawl_attempt = crawl_attempt
    end

    def success_pages
      @success_pages ||= crawl_attempt.crawl_pages.where("result->'error' IS NULL")
    end

    def produce!
      logger.tagged crawl_attempt_id: crawl_attempt.id do
        code = code_for_content_language
        logger.info "Language detected", code: code
        dictionary = LanguageDetector.dictionary_for_code(code)

        records_to_insert = []
        all_words.each do |word, details|
          if dictionary.check?(word)
            next
          end

          records_to_insert.push(
            account_id: crawl_attempt.account_id,
            property_id: crawl_attempt.property_id,
            crawl_attempt_id: crawl_attempt.id,
            word: word,
            seen_on_pages: details[:seen_on_pages].to_a,
            count: details[:count],
            suggestions: dictionary.suggest(word).first(8),
            created_at: Time.now.utc,
            updated_at: Time.now.utc,
          )
        end

        crawl_attempt.misspelled_words.destroy_all
        MisspelledWord.insert_all(records_to_insert)
      end
    end

    def all_words
      words = {}

      success_pages.find_each do |page|
        page.result["textElements"].each do |element|
          BlobProcessor.new(element["text"]).normalized_word_details.each do |word, count|
            words[word] ||= { word: word, seen_on_pages: Set.new, count: 0 }
            words[word][:seen_on_pages].add(page.url)
            words[word][:count] += count
          end
        end
      end

      words
    end

    def code_for_content_language
      logger.info "Fetching successful text blog pages"
      first_results = success_pages.limit(20).to_a
      sample_text = first_results
        .map { |result| result.result["textElements"] || [] }
        .flatten
        .map { |element| element["text"] }
        .filter(&:present?)
        .reduce { |a, b| a + "\n" + b }

      logger.info "Detecting language"
      if sample_text.present?
        LanguageDetector.code_for_text(sample_text)
      else
        "en-US"
      end
    end
  end
end
