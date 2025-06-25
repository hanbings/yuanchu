///|
fn new_debug_state(tokens : Array[Token]) -> DebugState {
  let state = DebugState::{
    tokens,
    tape: Array::make(30000, 0),
    output_buffer: @buffer.new(),
    jump_forward: @moonbitlang/core/hashmap.new(),
    jump_backward: @moonbitlang/core/hashmap.new(),
    pc: 0,
    ptr: 0,
    stack: Array::new(),
  }

  // Avoid runtime lookup of loop bodies.
  for index, token in tokens {
    match token {
      Token::LoopStart => state.stack.push(index)
      Token::LoopEnd => {
        let ele = state.stack.pop()
        match ele {
          Some(ele) => {
            state.jump_forward.set(ele, index)
            state.jump_backward.set(index, ele)
          }
          None => {
            println("Unmatched `]` at position \{index}")
            panic()
          }
        }
      }
      _ => ()
    }
  }
  if not(state.stack.is_empty()) {
    println("Unmatched `[` at position \{state.stack[0]}")
    panic()
  }
  state
}

///|
fn print_debug_help() -> Unit {
  let help =
    #| The following commands are supported:
    #| "c" or "continue" - Continue to execute subsequent instructions.
    #| "q" or "exit" - Exit the current interpreter.
    #| "r" or "reset" - Reset all state of the interpreter.
    #| "h" or "help" - Print help.
    #| "step" or Enter key - Execute the next Brainfuck instruction.
    #|
    #| If do nothing, the interpreter will probably do nothing too.
    #|
  println(help)
}

///|
pub fn debug_run(tokens : Array[Token]) -> Unit {
  let mut state = new_debug_state(tokens)
  println("✨ YuanChu's debugger!")
  print_debug_help()

  // request input
  for {
    let res = wait_inputs()
    // 1: continue
    // 2: exit
    // 3: reset
    // 4: help
    // 5: Enter key
    match res {
      1 =>
        while state.pc < state.tokens.length() {
          let result = debug_execute(state)
          if not(result) {
            println(
              "⚠ Because you used the ! syntax, the interpreter outputs all cells with content below. Press Enter to continue.",
            )
            println(state.tape.filter(fn(tape) { tape != 0 }))
            let _ = wait_inputs()

          }
        }
      2 => break
      3 => state = new_debug_state(tokens)
      4 => print_debug_help()
      5 => {
        let result = debug_execute(state)
        if not(result) {
          println(state.tape.filter(fn(tape) { tape != 0 }))
        }
      }
      _ => println("Unknown debugger command.")
    }
  }
}

///|
pub fn debug_execute(state : DebugState) -> Bool {
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
        state.pc = state.jump_forward.get(state.pc).unwrap()
      }
    Token::LoopEnd =>
      if state.tape[state.ptr] != 0 {
        state.pc = state.jump_backward.get(state.pc).unwrap()
      }
    Token::Debug => {
      state.pc += 1
      return false
    }
  }
  state.pc += 1
  true
}
