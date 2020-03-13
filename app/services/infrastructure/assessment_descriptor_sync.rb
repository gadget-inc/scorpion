# frozen_string_literal: true
module Infrastructure
  CACHE_PATH = Rails.root.join("db", "assessment_descriptor_cache.json")
  # Devtime assistant for importing production content for issue descriptors
  class AssessmentDescriptorSync
    def import_report
      import(fetch_remote)
    end

    def fetch_remote
      url = "https://scorpion-admin.gadget.dev/assessment/descriptors/dump"
      token = ENV.fetch("DEV_ACCESS_TOKEN")

      response = RestClient::Request.execute(
        method: :get,
        url: url,
        headers: { :Authorization => "Bearer #{token}", accept: :json },
      )

      JSON.parse(response.body)
    end

    def load_cache
      JSON.parse(File.read(CACHE_PATH))
    end

    def save_cache(attributes)
      File.open(CACHE_PATH, "w") { |file| file.write(JSON.dump(attributes)) }
    end

    def import(attributes)
      existings = Assessment::Descriptor.all.to_a.index_by(&:key)
      attributes.each do |blob|
        instance = existings[blob["key"]] || Assessment::Descriptor.new
        instance.assign_attributes(blob.except("id"))
        if instance.changed?
          instance.save!
        end
      end
    end
  end
end
