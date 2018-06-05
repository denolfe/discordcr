module Discord
  class Iterator(T)
    include ::Iterator(T)

    enum Direction
      Down
      Up
    end

    def initialize(@start_id : UInt64, @page_size : Int32,
                   @limit : Int32, &@block : UInt64 -> Tuple(Array(T), UInt64))
      @total = 0
      @objects = Array(T).new(page_size)
    end

    def next
      index = @total % @page_size
      if @objects.empty? || index.zero?
        @objects, @start_id = @block.call(@start_id)
      end

      @total += 1_u64
      @objects[index]? || stop
    end
  end
end
