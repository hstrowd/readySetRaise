module TestHelpers
  def generate_random_words(length = 8, min_length = 3, max_length = 9)
    words = ""
    length.times do
      words += " " + generate_random_string(min_length + rand(max_length - min_length))
    end
    return words
  end

  def generate_random_string(length = 8)
    return (0...length).map { ('a'..'z').to_a[rand(26)] }.join
  end
end
