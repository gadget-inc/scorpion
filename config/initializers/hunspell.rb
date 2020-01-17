# frozen_string_literal: true
FFI::Hunspell.directories = [Rails.root.join("db", "spelling", "dictionaries").to_s]
