# dlco_system
big homework for dlco-exp

# 设备支持

* VGA
* 键盘
* 时钟

# 内存布局规定

```
imem: [0x00000000, 0x0001ffff) 指令
dmem: [0x00100000, 0x0011ffff) 数据
vram: [0x00200000, 0x00201000) 显存，行优先
key : [0x00300000, 0x003fffff) 键盘
clk :  0x00400000              时钟

```