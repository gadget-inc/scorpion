# frozen_string_literal: true

module Timeline
  include SemanticLogger::Loggable

  class Producer
    def initialize(property)
      @property = property
    end

    def produce!
      @property.property_timeline_entries.destroy_all

      previous_screenshot = nil
      @property.property_screenshots.order("created_at ASC").find_each do |screenshot|
        if !previous_screenshot.nil?
          create_diff(previous_screenshot, screenshot)
        end

        previous_screenshot = screenshot
      end
    end

    def create_diff(previous_screenshot, current_screenshot)
      previous_screenshot.image.open do |previous_file|
        current_screenshot.image.open do |current_file|
          Dir.mktmpdir do |diff_dir|
            diff_file = File.join(diff_dir, "diff.png")
            compare = MiniMagick::Tool::Compare.new(whiny: false)
            compare.metric("SSIM")
            compare << previous_file.path
            compare << current_file.path
            compare << diff_file

            score = 0
            compare.call do |stdout, stderr, status|
              if status.to_i == 2
                raise "MiniMagick command failed with status=#{status}. stdout=#{stdout} stderr=#{stderr}"
              end
              score = stderr.chomp.to_f
            end

            if score < 1
              entry = @property.property_timeline_entries.create!(
                account_id: @property.account_id,
                entry_at: current_screenshot.created_at,
                entry_type: "screenshot_change",
                entry: {},
              )
              entry.image.attach(
                io: File.open(diff_file),
                filename: "diff.png",
                content_type: "image/png",
                identify: false,
              )
            end
          end
        end
      end
    end
  end
end
