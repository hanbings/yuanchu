///|
pub fn lex(source : String) -> Array[Token] {
  source
  .split("\n")
  .map(fn(line) {
    line
    .trim(" ")
    .split("#")
    .nth(0)
    .map_or("", fn(line) { line.trim(" ").to_string() })
  })
  .flat_map(fn(line) { line.split("") })
  .map(fn(char) {
    match char {
      ">" => Token::IncPtr
      "<" => Token::DecPtr
      "+" => Token::IncData
      "-" => Token::DecData
      "." => Token::Output
      "," => Token::Input
      "[" => Token::LoopStart
      "]" => Token::LoopEnd
      _ => {
        println("Unknown token: " + char.to_string())
        panic()
      }
    }
  })
  .collect()
}
