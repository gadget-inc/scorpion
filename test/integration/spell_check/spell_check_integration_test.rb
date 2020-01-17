# frozen_string_literal: true
require "test_helper"

class SpellCheck::SpellCheckIntegrationtest < ActiveSupport::TestCase
  setup do
    @property = create(:sole_destroyer_property)
    @crawler = Crawler::ExecuteCrawl.new(@property.account, maxDepth: 1)
  end

  test "there's spelling errors identified in the crawl" do
    attempt_record = @crawler.collect_text_blocks_crawl(@property, "test")
    assert attempt_record.succeeded
    producer = SpellCheck::Producer.new(attempt_record)

    assert_changes -> { MisspelledWord.count } do
      producer.produce!
    end

    attempt_record.reload
    first_word = attempt_record.misspelled_words.first
    assert_operator 0, :<, first_word.count
    assert_operator 0, :<, first_word.seen_on_pages.size
  end
end
