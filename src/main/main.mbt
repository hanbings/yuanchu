fn run(code: String, _input: String) -> Unit {
    let tape = Array::make(30000, 0)
    let mut ptr = 0;
    let mut pc = 0;

    let code = code.to_array()
    while pc < code.length() {
        match code[pc] {
            '>' => ptr += 1
            '<' => ptr -= 1
            '+' => tape[ptr] = tape[ptr] + 1
            '-' => tape[ptr] = tape[ptr] - 1
            '.' => {
                let output = tape[ptr]
                if output < 0 {
                    println("FINISHED")
                } else {
                    println({Char::from_int(tape[ptr])})
                }
            }
            '[' => {
                if tape[ptr] == 0 {
                    let mut loop_level = 1
                    while loop_level > 0 {
                        pc += 1;
                        match code[pc] {
                            '[' => loop_level += 1
                            ']' => loop_level -= 1
                            _ => ()
                        }
                    }
                }
            }
            ']' => {
                if tape[ptr] != 0 {
                    let mut loop_level = 1;
                    while loop_level > 0 {
                        pc -= 1
                        match code[pc] {
                            ']' => loop_level += 1
                            '[' => loop_level -= 1
                            _ => ()
                        }
                    }
                }
            }
            _ => ()
        }
        pc += 1;
    }
}

fn main {
    let code = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.";
    let input = "";
    let _ = run(code, input);
}
 