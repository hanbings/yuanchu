///|
pub struct State {
  tape : Array[Int]
  output_buffer : @buffer.Buffer
  mut ptr : Int
}

///|
pub fn run(ast : Array[AstNode]) -> Unit {
  let state = State::{
    tape: Array::make(30000, 0),
    output_buffer: @buffer.new(),
    ptr: 0,
  }
  execute(ast, state)
}

///|
fn execute(ast : Array[AstNode], state : State) -> Unit {
  for node in ast {
    match node {
      AstNode::Command(Token::IncPtr) => state.ptr += 1
      AstNode::Command(Token::DecPtr) => state.ptr -= 1
      AstNode::Command(Token::IncData) => state.tape[state.ptr] += 1
      AstNode::Command(Token::DecData) => state.tape[state.ptr] -= 1
      AstNode::Command(Token::Output) => {
        let output_char = Char::from_int(state.tape[state.ptr])
        if output_char == '\n' {
          println(state.output_buffer)
          state.output_buffer.reset()
          continue
        }
        state.output_buffer.write_char(output_char)
      }
      AstNode::Command(Token::Input) => println("Input: Not Supported Yet")
      AstNode::Loop(loop_body) =>
        while state.tape[state.ptr] != 0 {
          execute(loop_body, state)
        }
      _ => println("Unknown")
    }
  }
}
