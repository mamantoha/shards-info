class HTTP::Server
  class Response < IO
    private def unbuffered_write(slice : Bytes) : Nil
      return if slice.empty?

      if response.headers["Transfer-Encoding"]? == "chunked"
        @chunked = true
      elsif !response.wrote_headers?
        if response.version != "HTTP/1.0" && !response.headers.has_key?("Content-Length")
          response.headers["Transfer-Encoding"] = "chunked"
          @chunked = true
        end
      end

      ensure_headers_written

      if @chunked
        slice.size.to_s(@io, 16)
        @io << "\r\n"
        @io.write(slice)
        @io << "\r\n"
      else
        @io.write(slice)
      end
    rescue ex : IO::Error
      unbuffered_close
      # raise ClientError.new("Error while writing data to the client", ex)
    end
  end
end
