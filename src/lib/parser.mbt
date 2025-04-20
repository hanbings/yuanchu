///|
pub fn parse(tokens : Array[Token]) -> Array[AstNode] {
  let (loop_nodes, _result) = parse_loop(tokens, 0)
  loop_nodes
}

///|
fn parse_loop(tokens : Array[Token], count : Int) -> (Array[AstNode], Int) {
  let mut count = count
  let nodes = Array::new()
  while count < tokens.length() {
    let token = tokens[count]
    match token {
      Token::LoopStart => {
        let (loop_nodes, result) = parse_loop(tokens, count + 1)
        count = result
        nodes.push(AstNode::Loop(loop_nodes))
      }
      Token::LoopEnd => break
      _ => nodes.push(AstNode::Command(token))
    }
    count += 1
  }
  (nodes, count)
}
