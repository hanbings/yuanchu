use std::io::stdin;

use termion::{event::Key, input::TermRead};

#[unsafe(no_mangle)]
pub extern "C" fn byte_to_uint(l: u32, r: u32) -> u32 {
    let bytes: [u8; 2] = [l as u8, r as u8];
    
    let trimmed = bytes.split(|&b| b == 0).next().unwrap_or(&[]);
    match std::str::from_utf8(trimmed)
        .ok()
        .and_then(|s| s.parse::<u32>().ok()) 
    {
        Some(n) => n,
        None => 0,
    }
}

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
            "r" | "reset" => return 3,
            "h" | "help" => return 4,
            "" | "step" => return 5,
            ">" => return 6,
            "<" => return 7,
            "+" => return 8,
            "-" => return 9,
            "." => return 10,
            "," => return 11,
            "[" => return 12,
            "]" => return 13,
            "!" => return 14,
            "d" | "dump" => return 15,
            "l" | "load" => return 16,
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

use std::alloc::{alloc, Layout};
use std::ptr;

#[unsafe(no_mangle)]
pub extern "C" fn alloc_hello() -> *mut u8 {
    let msg = b"hello";
    let len = msg.len();
    unsafe {
        let layout = Layout::array::<u8>(len).unwrap();
        let ptr = alloc(layout);
        if ptr.is_null() {
            return ptr::null_mut();
        }
        ptr.copy_from_nonoverlapping(msg.as_ptr(), len);
        ptr
    }
}