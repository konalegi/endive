module Endive
  class SymHash < Hash

    # Returns a Hash that allows values to be fetched with String or
    # Symbol keys.
    def initialize h = nil
      super(){ |hash,key| hash[key.to_s] if Symbol === key }
      unless h.nil?
        merge! h

        # Replace values that are Hashes with SymHashes, recursively.
        each do |k,v|
          self[k] = case v
                    when Hash
                      SymHash.new(v)
                    when Array
                      v.map {|e| Hash === e ? SymHash.new(e) : e}
                    else
                      v
                    end
        end
      end
    end
  end
end