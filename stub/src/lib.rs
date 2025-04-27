use std::{ffi::c_int, io::stdin};

use termion::{event::Key, input::TermRead};

#[unsafe(no_mangle)]
pub extern "C" fn print_input(input: c_int) {
    print!("{}", input);
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
