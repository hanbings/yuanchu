///|
fn main {
  let args = @moonbitlang/x/sys.get_cli_args()

  // check arguments
  let help = args.contains("--help")
  let file = {
    let mut file = None
    args.eachi(fn(i, arg) {
      if arg == "--file" {
        if args.length() >= i + 1 {
          file = Some(args[i + 1])
        } else {
          println("Error: --file option requires a file name")
          return
        }
      }
    })
    file
  }
  let step = args.contains("--step")
  let jit = args.contains("--jit")

  // execute the corresponding parameters.
  if help {
    let help =
      #| Usage: mbt [options] [file]
      #| Options:
      #|   --help       Show this help message
      #|   --step       Run the program step by step
      #|   --jit        Use JIT compilation
      #|   --file FILE  Specify the file to run
    println(help)
    return
  }

  // verify the source code file path.
  let file_path = match file {
    Some(file) => file
    None => {
      println(
        "Error: requires a file to be passed in using the --file option to execute.",
      )
      return
    }
  }

  // parse code into tokens and convert it to ast
  let code = try {
    @fs.read_file_to_string!(file_path)
  } catch {
    _ => return
  }
  let token = @lib.lex(code)
  let ast = @lib.parse(token)

  // check if the code is valid and run it step by step.
  if step {
    @lib.debug_run(token)
    return
  }

  // running code as JIT.
  if jit {
    let machine_code = @lib.compile(ast)
    let result = @lib.run_asm(machine_code, machine_code.length().to_uint64())
    println(result)
    return
  }

  // running code as an interpreter.
  @lib.run(ast)
}
