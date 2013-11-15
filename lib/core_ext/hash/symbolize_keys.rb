class Hash
  def symbolize_keys(&select)
    dup.symbolize_keys!(&select)
  end

  def symbolize_keys!(&select)
    if select
      keys.each do |key|
        if select[key]
          new_key = (key.to_sym rescue key.to_s.to_sym)
          self[new_key] = delete(key)
        end
      end
    else
      keys.each do |key|
        new_key = (key.to_sym rescue key.to_s.to_sym)
        self[new_key] = delete(key)
      end
    end
    self
  end
end