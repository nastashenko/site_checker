require 'csv'

class SiteCheckerService
  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path.to_s
    raise ArgumentError, "File '#{file_path}' not found" unless file_exist?
  end

  def call
    puts 'Start'
    CSV.foreach(file_path) do |row|
      url = row.first
      next if url == 'URL' # skip first line

      response = get_response(url)
      puts [url, status(response.code)].join(': ')
    end
    puts 'End'
  rescue HTTParty::Error, SocketError => e
    puts 'not available'
  end

  private

  def file_exist?
    File.exist?(file_path)
  end

  def get_response(value)
    uri = URI.parse(value)
    HTTParty.get([(uri.scheme || 'http://'), uri.host || value].join)
  end

  def status(val)
    case val
    when 200
      'success'
    when 404
      'not found'
    when 500...600
      'server error'
    else
      "status: #{val}"
    end
  end
end

