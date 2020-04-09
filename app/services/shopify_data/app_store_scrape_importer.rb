# frozen_string_literal: true
require "csv"

# Imports a csv of scraped data from the app store into the database
# CSV headers expected to be web-scraper-order,web-scraper-start-url,app,app-href,title,developer-link,developer,developer-website,faq-link,app-category,rating,reviews,image-src
# CSV created using `Web Scraper` chrome extension, talk to Harry about it. Sitemap backup here: https://gist.github.com/airhorns/78f80e115be0083757062046cf7f91f6
class ShopifyData::AppStoreScrapeImporter
  def initialize(csv_file, limit: nil)
    @table = CSV.parse(File.read(csv_file), headers: true)
    @limit = limit
    @processed = Set.new
  end

  def import
    counter = 0
    @table.each_slice(50) do |row_slice|
      existing_index = ShopifyData::AppStoreApp.where(app_store_url: row_slice.map { |row| normalize_url(row["app-href"]) }).index_by(&:app_store_url)

      row_slice.each do |row|
        counter += 1
        url = normalize_url(row["app-href"])

        # During scraping the order of stuff can change such that we get duplicate entries. Dedupe them here.
        if @processed.include?(url)
          next
        else
          @processed << url
        end

        record = existing_index[url] || ShopifyData::AppStoreApp.new(app_store_url: url)
        record.assign_attributes(
          title: row["title"],
          app_store_developer_url: row["developer-link"],
          category: row["app-category"],
          developer_name: row["developer"],
          developer_url: row["developer-website"],
          faq_url: row["faq-link"],
          image_url: row["image-src"],
          priority: counter,
        )

        record.inferred_domains = [record.developer_url, record.faq_url, row["privacy-policy-link"]].compact.reject { |example_url| example_url == "null" }.map { |example_url| domain_from_url(example_url) }.uniq

        record.confirmed_domains ||= []
        record.save!
      end

      break if @limit.present? && counter >= @limit
    end
  end

  def normalize_url(url)
    parsed = URI.parse(url)
    parsed.fragment = parsed.query = nil
    parsed.to_s
  end

  def domain_from_url(url)
    Infrastructure::ThirdPartyWeb.instance.domain_from_origin_or_url(url)
  end
end
