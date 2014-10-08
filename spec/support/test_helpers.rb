module TestHelpers
  def generate_random_string(length = 8)
    return ('a'..'z').to_a.shuffle[0,length].join
  end
end
