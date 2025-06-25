///|
pub enum Token {
  IncPtr
  DecPtr
  IncData
  DecData
  Output
  Input
  LoopStart
  LoopEnd
  Debug
} derive(Eq, Compare, Show)

///|
pub enum AstNode {
  Command(Token)
  Loop(Array[AstNode])
} derive(Eq, Compare, Show)

///|
pub struct State {
  tape : Array[UInt]
  output_buffer : @buffer.Buffer
  mut ptr : Int
}

///|
pub struct ReplState {
  tokens : Array[Token]
  mut tape : Array[UInt]
  output_buffer : @buffer.Buffer
  mut pc : Int
  mut ptr : Int
  stack : Array[Int]
}

///|
pub struct DebugState {
  tokens : Array[Token]
  tape : Array[UInt]
  output_buffer : @buffer.Buffer
  jump_forward : @moonbitlang/core/hashmap.T[Int, Int]
  jump_backward : @moonbitlang/core/hashmap.T[Int, Int]
  mut pc : Int
  mut ptr : Int
  stack : Array[Int]
}
