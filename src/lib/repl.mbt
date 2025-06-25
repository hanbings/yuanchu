///|
fn new_repl_state() -> ReplState {
  ReplState::{
    tokens: Array::new(),
    tape: Array::make(30000, 0),
    output_buffer: @buffer.new(),
    pc: 0,
    ptr: 0,
    stack: Array::new(),
  }
}

///|
fn print_repl_help() -> Unit {
  let help =
    #| The following commands are supported:
    #| "c" or "continue" - Continue to execute subsequent instructions.
    #| "q" or "exit" - Exit the current interpreter.
    #| "r" or "reset" - Reset all state of the interpreter.
    #| "d" or "dump" - Dump tape.
    #| "l" or "load" - Load tape.
    #| "h" or "help" - Print help.
    #| "step" or Enter key - Execute the next Brainfuck instruction.
    #| ">" "<" "+" "-" "." "," "[" "]" "!" - These are the instructions supported by the interpreter, 
    #|                                       and typing these characters will store them into the instructions.
    #|                                       Enter one character at a time.
    #|
    #| If do nothing, the interpreter will probably do nothing too.
    #|
  println(help)
}

///|
fn print_memory(state : ReplState) -> Unit {
  println(
    state.tape[:state.tape.length() -
    state.tape.rev().search_by(fn(x) { x != 0 }).or_else(fn() { 0 })],
  )
}

///|
pub fn repl_run() -> Unit {
  let mut state = new_repl_state()
  println("✨ YuanChu's REPL!")
  print_repl_help()

  // request input
  for {
    let res = wait_inputs()
    // 1: continue
    // 2: exit
    // 3: reset
    // 4: help
    // 5: Enter key
    // 6 - 14: token
    // 15: dump
    // 16: load
    match res {
      1 =>
        while state.pc < state.tokens.length() {
          let result = repl_execute(state)
          if not(result) {
            println(
              "⚠ Because you used the ! syntax, the interpreter outputs all cells with content below. Press Enter to continue.",
            )
            print_memory(state)
            break
          }
        }
      2 => break
      3 => state = new_repl_state()
      4 => print_repl_help()
      5 => {
        let result = repl_execute(state)
        if not(result) {
          print_memory(state)
        }
      }
      6 => state.tokens.push(Token::IncPtr)
      7 => state.tokens.push(Token::DecPtr)
      8 => state.tokens.push(Token::IncData)
      9 => state.tokens.push(Token::DecData)
      10 => state.tokens.push(Token::Output)
      11 => state.tokens.push(Token::Input)
      12 => state.tokens.push(Token::LoopStart)
      13 => state.tokens.push(Token::LoopEnd)
      14 => state.tokens.push(Token::Debug)
      15 => dump(state.tape)
      16 => state.tape = load()
      _ => println("Unknown REPL mode command.")
    }
  }
}

///|
pub fn repl_execute(state : ReplState) -> Bool {
  match state.tokens[state.pc] {
    Token::IncPtr => state.ptr += 1
    Token::DecPtr => state.ptr -= 1
    Token::IncData => state.tape[state.ptr] += 1
    Token::DecData => state.tape[state.ptr] -= 1
    Token::Output => {
      let output_char = Char::from_int(state.tape[state.ptr].to_int())
      if output_char == '\n' {
        println(state.output_buffer)
        state.output_buffer.reset()
        state.pc += 1
        return true
      }
      state.output_buffer.write_char(output_char)
    }
    Token::Input => state.tape[state.ptr] = wait_input()
    Token::LoopStart =>
      if state.tape[state.ptr] == 0 {
        // forward to matching ]
        let mut depth = 1
        while depth > 0 {
          state.pc += 1
          if state.pc >= state.tokens.length() {
            println("Unmatched `[`")
            panic()
          }
          match state.tokens[state.pc] {
            Token::LoopStart => depth += 1
            Token::LoopEnd => depth -= 1
            _ => ()
          }
        }
      }
    Token::LoopEnd =>
      if state.tape[state.ptr] != 0 {
        // backward to matching [
        let mut depth = 1
        while depth > 0 {
          if state.pc == 0 {
            println("Unmatched `]`")
            panic()
          }
          state.pc -= 1
          match state.tokens[state.pc] {
            Token::LoopEnd => depth += 1
            Token::LoopStart => depth -= 1
            _ => ()
          }
        }
      }
    Token::Debug => {
      state.pc += 1
      return false
    }
  }
  state.pc += 1
  true
}
