![Yuan Chu](resources/logo.png)

# 鹓鶵 （yuān chú）

> 凤象者五，五色而赤者凤；黄者鹓鶵； - 《小学绀珠》
> 
> 南方有鸟，其名鹓雏，非梧桐不止，非练实不食，非醴泉不饮。 - 《庄子·秋水》


这是一个 Brainfuck 解释器。

## 构建与运行

> [!NOTE]
> 需要：Rust 工具链以及 Moonbit 工具链。
> 
> 您可以从 https://www.rust-lang.org/learn/get-started 查看如何安装 Rust 工具链，以及在 https://www.moonbitlang.cn/download 查看如何安装 Moonbit 工具链

> [!TIP]
> 默认使用 Linux 发行版作为开发环境。

```bash
$ git clone git@github.com:hanbings/yuanchu.git

# 构建 rust stub 包，它将是一个动态链接库供 moonbit 调用
$ cd stub
$ cargo build
# 使用下面的指令查看是否构建成功，sha 值可能会有所区别，但它至少是一个 elf 文件
$ file target/debug/libyuanchu_stub.so 
target/debug/libyuanchu_stub.so: ELF 64-bit LSB shared object, x86-64
version 1 (SYSV), dynamically linked, BuildID[sha1]=de9d3e8220d1e53f6371bfb8394aeb4cd3e02ad5
with debug_info, not stripped

# 回到代码根目录
$ cd ..
$ moon build --target native

# 然后运行它！
$ LD_LIBRARY_PATH=stub/target/debug target/native/release/build/main/main.exe
Hello World!

# 以 JIT 方式运行
$ LD_LIBRARY_PATH=stub/target/debug target/native/release/build/main/main.exe --jit
```

## 实现

[用 MoonBit 写了个带有 JIT 的 Brainfuck 解释器](./moonbit-brainfuck.md)