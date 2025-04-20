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
} derive(Eq, Compare, Show)

///|
pub enum AstNode {
  Command(Token)
  Loop(Array[AstNode])
} derive(Eq, Compare, Show)
