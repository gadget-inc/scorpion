# frozen_string_literal: true
require "English"
require "optparse"

namespace :job do
  desc "Run a Que job inline. Used by other infrastructure components"
  task :run_inline => :environment do
    options = { args: [] }

    optparse = OptionParser.new do |opts|
      opts.on("-j", "--job-class ARG", "what job class to execute") do |klass|
        options[:job_class] = klass.constantize
      end

      opts.on("-a", "--args ARG", "JSON serialized array of arguments to pass to class") do |args|
        options[:args] = JSON.parse(args)
      end

      opts.on("-h", "--help", "Display this screen") do
        puts opts
        exit
      end
    end

    begin
      args = optparse.order!(ARGV) { }
      optparse.parse!(args)

      mandatory = [:job_class]
      missing = mandatory.select { |param| options[param].nil? }
      if !missing.empty?
        puts "Missing options: #{missing.join(", ")}"
        puts optparse
        exit
      end
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      puts $ERROR_INFO.to_s
      puts optparse
      exit
    end

    Rails.logger.info "Running job inline", job_class: options[:job_class], args: options[:args]
    options[:job_class].run(*options[:args])
    true
  end
end
