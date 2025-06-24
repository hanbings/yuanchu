use std::io::stdin;

use termion::{event::Key, input::TermRead};

#[unsafe(no_mangle)]
pub extern "C" fn wait_input() -> u32 {
    let stdin = stdin();
    let stdin = stdin.lock();

    if let Some(Ok(c)) = stdin.keys().next() {
        match c {
            Key::Char(ch) => {
                return ch as u32;
            }
            _ => {}
        }
    }

    0
}

#[unsafe(no_mangle)]
pub extern "C" fn wait_inputs() -> u32 {
    let stdin = stdin();
    let mut stdin = stdin.lock();

    if let Ok(Some(inputs)) = stdin.read_line() {
        match inputs.as_str() {
            "c" | "continue" => return 1,
            "q" | "exit" => return 2,
            "d" | "dump" => return 3,
            "l" | "load" => return 4,
            "r" | "reset" => return 5,
            "h" | "help" => return 6,
            "" | "step" => return 7,
            _ => {}
        }   
    }
    
    0
}

/// This interface is reserved for JIT optimization.
/// It accepts the machine code in the form of bytes passed from
/// the calling side and places it in the memory to execute it as a function call.
///
/// It currently only supports x86.
#[unsafe(no_mangle)]
extern "C" fn run_asm(code: *const u8, size: u64) -> u64 {
    let code = unsafe { std::slice::from_raw_parts(code, size as usize) };
    let code = code.to_vec();

    use libc::{MAP_ANON, MAP_PRIVATE, PROT_EXEC, PROT_READ, PROT_WRITE, mmap, mprotect, munmap};
    use std::mem::transmute;
    use std::ptr::{copy_nonoverlapping, null_mut};

    unsafe {
        let size = code.len();
        let addr = mmap(
            null_mut(),
            size,
            PROT_READ | PROT_WRITE,
            MAP_PRIVATE | MAP_ANON,
            -1,
            0,
        );

        if addr == libc::MAP_FAILED {
            panic!("mmap failed");
        }

        copy_nonoverlapping(code.as_ptr(), addr as *mut u8, size);
        if mprotect(addr, size, PROT_EXEC) != 0 {
            panic!("mprotect failed");
        }

        let mut cells = vec![0u8; 30000];
        let func: extern "C" fn(cells: *mut u8) -> u64 = transmute(addr);
        let result = func(cells.as_mut_ptr());

        munmap(addr, size);

        result
    }
}
