pub extern "C" fn byte_to_uint(l: UInt, r: UInt) -> UInt = "byte_to_uint"

///| In the future it should be moved out of lib and passed to the caller as a callback to be compatible with multiple backends.
pub extern "C" fn wait_input() -> UInt = "wait_input"

///|
pub extern "C" fn wait_inputs() -> UInt = "wait_inputs"

///| 
pub extern "C" fn run_asm(code : FixedArray[Byte], size : UInt64) -> UInt64 = "run_asm"
