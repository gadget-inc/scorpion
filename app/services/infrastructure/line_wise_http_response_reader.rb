# frozen_string_literal: true

# Streaming iterator that yields full lines from an iterable HTTP response body of bytes
class Infrastructure::LineWiseHttpResponseReader
  def initialize(response)
    @response = response
  end

  def each_line
    remainings = ""
    @response.read_body do |chunk|
      chunk = remainings + chunk

      while (i = chunk.index("\n"))
        yield chunk[0..i]
        chunk = chunk[i + 1..-1]
      end

      remainings = chunk
    end

    if !remainings.empty?
      yield remainings
    end
  end
end
