///|
pub fn parse(tokens : Array[Token]) -> Array[AstNode] {
  let count: Ref[Int] = { val: 0 }
  let loop_nodes = parse_loop(tokens, count)
  loop_nodes
}

///|
fn parse_loop(tokens : Array[Token], count : Ref[Int]) -> Array[AstNode] {
  let nodes = Array::new()
  while count.val < tokens.length() {
    let token = tokens[count.val]
    match token {
      Token::LoopStart => {
        count.val += 1
        let loop_nodes = parse_loop(tokens, count)
        nodes.push(AstNode::Loop(loop_nodes))
      }
      Token::LoopEnd => break
      _ => nodes.push(AstNode::Command(token))
    }
    count.val += 1
  }
  nodes
}
