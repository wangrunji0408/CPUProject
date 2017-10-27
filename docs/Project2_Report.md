# ALU实验报告

计53 王润基 张耀楠 杨跻云

## 实验内容

用VHDL实现简单ALU模块，外加状态机控制输入输出。用ISE编译并在教学计算机上验证。

## 实验过程及结果

### 开发流程

第一步：

我们使用开源VHDL编译仿真器nvc/ghdl，进行语法检查和功能仿真。使用任意文本编辑器进行开发。好处是开发环境十分轻量，编译仿真速度极快，还可以生成波形图Debug。当全部测试通过后，进入下一步。

第二步：

在ISE中导入代码，进行引脚绑定等相关设置。编译，然后进行时序仿真。

第三步：

下载到开发板上最终测试。

### 分工

* 王润基：搭建框架和Top模块测试
* 张耀楠：Top模块（状态机）
* 杨跻云：ALU模块

### 结果

最终，功能仿真通过了全部测例。按测试描述的过程上板子验证无误。

实验数据记录表，用测试代码代替如下，详细测试过程可见`test_top.vhd`。

```vhdl
test_case("ADD", clk, input, fout, x"0002", x"FFFF", OP_ADD, x"0001", "1000");
test_case("SUB", clk, input, fout, x"0002", x"0004", OP_SUB, x"FFFE", "1010");
test_case("AND", clk, input, fout, x"0003", x"0005", OP_AND, x"0001", "0000");
test_case("OR", clk, input, fout, x"0002", x"0004", OP_OR, x"0006", "0000");
test_case("XOR", clk, input, fout, x"0002", x"0004", OP_XOR, x"0006", "0000");
test_case("NOT", clk, input, fout, x"0002", x"0004", OP_NOT, x"FFFD", "0010");
test_case("SLL", clk, input, fout, x"ABCD", x"0004", OP_SLL, x"BCD0", "0010");
test_case("SRL", clk, input, fout, x"ABCD", x"0004", OP_SRL, x"0ABC", "0000");
test_case("SRA", clk, input, fout, x"FFF8", x"0002", OP_SRA, x"FFFE", "0010");
test_case("ROL", clk, input, fout, x"ABCD", x"0004", OP_ROL, x"BCDA", "0010");
```



## 遇到的问题

1. 在实验室现场，两台笔记本（Mac+Win10虚拟机，Ubuntu）的ISE不识别板子，浪费了一节课时间。最终使用机房的台式机才得以烧写。到现在本组只有一个人的电脑可以用来烧板子。

2. 测试时遇到这样的现象：每次Reset后的第一轮操作没有问题，之后会不定期地出Bug。一开始猜测是状态机写错了。然后我们使用数码管显示当前状态，发现有时按一次按钮实际跳过了两个状态，这个现象在以前数电实验中也出现过。

   教训是：一定要输出调试信息表征内部状态。

## 思考题

1. 组合逻辑电路
2. D触发器