///|
pub fn compile(nodes : Array[AstNode]) -> FixedArray[Byte] {
  let buffer : Ref[Array[Byte]] = { val: [] }

  // function prologue
  buffer.val.push_iter(
    [
      // push rbx
      // because rbx is used to store the pointer to the cells,
      // and we shoud restore it at the end
      (0x53).to_byte(),
      // mov rbx, rdi
      // rdi is the pointer to the cells, 
      // from the first argument of the function calling
      0x48,
      0x89,
      0xfb,
    ].iter(),
  )

  // Extract compilation functionality into functions to handle loops recursively.
  nodes.iter().each(fn(node) { compile_loop(node, buffer) })

  // function epilogue
  buffer.val.push_iter(
    [
      // mov rax, [rbx]
      (0x48).to_byte(),
      0x8b,
      0x03,
      // pop rbx
      0x5b,
      // ret
      0xc3,
    ].iter(),
  )

  // return the compiled code, should be in a fixed array
  FixedArray::from_array(buffer.val)
}

///|
pub fn compile_loop(node : AstNode, buffer : Ref[Array[Byte]]) -> Unit {
  match node {
    AstNode::Command(Token::IncPtr) => buffer.val.push_iter(inc_pointer())
    AstNode::Command(Token::DecPtr) => buffer.val.push_iter(dec_pointer())
    AstNode::Command(Token::IncData) => buffer.val.push_iter(inc_cell())
    AstNode::Command(Token::DecData) => buffer.val.push_iter(dec_cell())
    AstNode::Command(Token::Output) => buffer.val.push_iter(syscall_write())
    AstNode::Command(Token::Input) => buffer.val.push_iter(syscall_read())
    AstNode::Command(Token::LoopStart) => println("LoopStart")
    AstNode::Command(Token::LoopEnd) => println("LoopEnd")
    AstNode::Loop(loop_nodes) => {
      let loop_start = buffer.val.length()

      // cmp byte ptr [rbx], 0
      let cmp : Array[Byte] = [0x80, 0x3b, 0x00]
      buffer.val.push_iter(cmp.iter())

      // je forward, <offset>
      let placeholder : Array[Byte] = [0x0f, 0x84, 0, 0, 0, 0]
      buffer.val.push_iter(placeholder.iter())
      let je_pos = buffer.val.length() - 4

      // compile the loop body
      loop_nodes.iter().each(fn(n) { compile_loop(n, buffer) })

      // cmp byte ptr [rbx], 0
      let back_offset = loop_start - (buffer.val.length() + 5)
      buffer.val.push(0xe9)
      buffer.val.push_iter(int32_le_bytes(back_offset).iter())
      let loop_end = buffer.val.length()
      let forward_offset = loop_end - (je_pos + 4)

      // write the offset to the placeholder
      let bytes = int32_le_bytes(forward_offset)
      buffer.val[je_pos] = bytes[0]
      buffer.val[je_pos + 1] = bytes[1]
      buffer.val[je_pos + 2] = bytes[2]
      buffer.val[je_pos + 3] = bytes[3]
    }
  }
}

///|
fn int32_le_bytes(n : Int) -> Array[Byte] {
  [
    (n & 0xff).to_byte(),
    ((n >> 8) & 0xff).to_byte(),
    ((n >> 16) & 0xff).to_byte(),
    ((n >> 24) & 0xff).to_byte(),
  ]
}

///|
pub fn inc_pointer() -> Iter[Byte] {
  let code : Array[Byte] = [
    // inc rbx
    0x48, 0xff, 0xc3,
  ]
  code.iter()
}

///|
pub fn dec_pointer() -> Iter[Byte] {
  let code : Array[Byte] = [
    // dec rbx
    0x48, 0xff, 0xcb,
  ]
  code.iter()
}

///|
pub fn inc_cell() -> Iter[Byte] {
  let code : Array[Byte] = [
    // inc byte [rbx]
    0xfe, 0x03,
  ]
  code.iter()
}

///|
pub fn dec_cell() -> Iter[Byte] {
  let code : Array[Byte] = [
    // dec byte [rbx]
    0xfe, 0x0b,
  ]
  code.iter()
}

///|
pub fn syscall_read() -> Iter[Byte] {
  // read 1 byte to the address in rbx
  let code : Array[Byte] = [
    // mov rax, 0
    0x48, 0xc7, 0xc0, 0x00, 0x00, 0x00, 0x00,
    // mov rdi, 0
     0x48, 0xc7, 0xc7, 0x00, 0x00, 0x00, 0x00,
    // mov rsi, rbx
     0x48, 0x89, 0xde,
    // mov rdx, 1
     0x48, 0xc7, 0xc2, 0x01, 0x00, 0x00, 0x00,
    // syscall
     0x0f, 0x05,
  ]
  code.iter()
}

///|
pub fn syscall_write() -> Iter[Byte] {
  let code : Array[Byte] = [
    // mov rax, 1
    0x48, 0xc7, 0xc0, 0x01, 0x00, 0x00, 0x00,
    // mov rdi, 1
     0x48, 0xc7, 0xc7, 0x01, 0x00, 0x00, 0x00,
    // mov rsi, rbx
     0x48, 0x89, 0xde,
    // mov rdx, 1
     0x48, 0xc7, 0xc2, 0x01, 0x00, 0x00, 0x00,
    // syscall
     0x0f, 0x05,
  ]
  code.iter()
}
