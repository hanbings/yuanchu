///|
fn dump(tape : Array[UInt]) -> Unit {
  let path = "yuanchu.dump"
  let content = tape.to_string()
  try {
    @fs.write_string_to_file!(path, content)
  } catch {
    e => println("Dump failed, error: \{e.to_string()}  data: \{content}")
  }
}

///|
fn load() -> Array[UInt] {
  let path = "yuanchu.dump"
  let code = try {
    @fs.read_file_to_string!(path)
  } catch {
    e => {
      println("Dump failed, error: \{e.to_string()}")
      ""
    }
  }
  let tape : Array[UInt] = Array::new()
  for
    b in code
    .replace_all(old="[", new="")
    .replace_all(old="]", new="")
    .replace_all(old=" ", new="")
    .split(",")
    .iter() {
      let bytes = b.to_string().to_bytes().to_array()
      if bytes.length() < 2 {
        tape.push(0)
        continue
      }

      let l = bytes.get(0).unwrap().to_uint()
      let r = bytes.get(1).unwrap().to_uint()
      
      tape.push(byte_to_uint(l, r))
  }
  tape
}