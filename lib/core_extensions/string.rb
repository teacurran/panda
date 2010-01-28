String::ALPHANUMERIC_CHARACTERS = ('a'..'z').to_a + ('A'..'Z').to_a
def String.random(size)
  length = String::ALPHANUMERIC_CHARACTERS.length
  (0...size).collect { String::ALPHANUMERIC_CHARACTERS[Kernel.rand(length)] }.join
end
