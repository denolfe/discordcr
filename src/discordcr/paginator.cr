module Discord
  class Paginator(T)
    include ::Enumerable(T)

    enum Direction
      Up
      Down
    end

    def initialize(@limit : Int32?, @direction : Direction,
                   &@block : Array(T)? -> Array(T))
      @count = 0
    end

    def each
      last_page = nil
      loop do
        page = @block.call(last_page)
        return if page.empty?

        iterator = if @direction.up?
                     page.reverse_each
                   else
                     page.each
                   end

        iterator.each do |item|
          yield(item)
          @count += 1
          @limit.try { |l| return if @count >= l }
        end

        last_page = page
      end
    end
  end
end
