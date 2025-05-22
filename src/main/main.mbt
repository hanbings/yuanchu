///|
fn main {
  let args = @moonbitlang/x/sys.get_cli_args()

  // check arguments
  let help = args.contains("--help")
  let step = args.contains("--step")
  let jit = args.contains("--jit")
  let file = {
    let mut file = None
    args.eachi(fn(i, arg) {
      if arg == "--file" {
        if i > i + 1 {
          file = Some(args[i + 1])
        } else {
          println("Error: --file option requires a file name")
          return
        }
      }
    })
    file
  }

  if help {
    println("Usage: mbt [options] [file]")
    println("Options:")
    println("  --help       Show this help message")
    println("  --step       Run the program step by step")
    println("  --jit        Use JIT compilation")
    println("  --file FILE  Specify the file to run")
    return
  }

  // if file is empty, run the hello world program
  if file.is_empty() {
    let code =
      #| ++++++++++             # cell[0] = 10
      #| [                      # loop 10 times
      #|   >+++++++             # cell[1] += 7 * 10 = 70
      #|   >++++++++++          # cell[2] += 10 * 10 = 100
      #|   >+++                 # cell[3] += 3 * 10 = 30
      #|   >+                   # cell[4] += 1 * 10 = 10
      #|   <<<<-                # back to cell[0], decrement
      #| ]
      #| >++.                   # print 'H' (cell[1] = 72)
      #| >+.                    # print 'e' (cell[2] = 101)
      #| +++++++.               # print 'l' (cell[2] = 108)
      #| .                      # print 'l'
      #| +++.                   # print 'o' (111)
      #| >++.                   # print ' ' (cell[3] = 32)
      #| <<+++++++++++++++.     # print 'W' (cell[1] = 87)
      #| >.                     # print 'o' (cell[2] = 111)
      #| +++.                   # print 'r' (114)
      #| ------.                # print 'l' (108)
      #| --------.              # print 'd' (100)
      #| >+.                    # print '!' (cell[3] = 33)
      #| >.                     # print newline (cell[4] = 10)
    let token = @lib.lex(code)
    let ast = @lib.parse(token)

    // check if the code is valid and run it step by step
    if step { }

    // run the code
    if jit {
      // jit
      let machine_code = @lib.compile(ast)
      let result = @lib.run_asm(machine_code, machine_code.length().to_uint64())
      println(result)
    } else {
      // run interpreter
      @lib.run(ast)
    }
  }
}
