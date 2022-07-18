Reusing the Logic analyzer
la_test2 tests

[Getting Started](https://caravel-harness.readthedocs.io/en/latest/getting-started.html)

32 IO ports

128 Logic Analyzer ports

```c
reg_la0_oenb = reg_la0_iena = 0x00000000;    // [31:0]
reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32]
reg_la2_oenb = reg_la2_iena = 0x00000000;    // [95:64]
reg_la3_oenb = reg_la3_iena = 0x00000000;    // [127:96]
```

Actual la data line

```c
reg_la2_data
```

Management SoC -> Serial Transfer IO configuration


Using wishbone or not

```verilog
assign la_write = ~la_oenb[63:32] & ~{BITS{valid}};
```
