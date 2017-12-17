# 计算机组成原理 大实验报告

计53 王润基 杨跻云 张耀楠

【奋战三星期 做台计算机】2017.11.14 - 2017.12.10

[TOC]

## 实现的功能

* 流水线CPU，最高频率40MHz
  * 支持25条基本指令和5条扩展指令
  * 支持外部中断
  * 取指Cache，缓解结构冲突
* 扩展功能
  * Boot：开机自动将程序从Flash拷贝到RAM
  * VGA和键盘
  * 实时显示丰富的调试信息，支持断点和单步调试
  * HardTerm：将Term移植到板上，可直接用键盘操作
  * 支持显存，可编程控制显示内容
  * 简单的MIPS16e编译器

## 性能测试结果

## 整体架构设计

### 整体架构

* CPU模块：
* Renderer模块：渲染器

### CPU架构

### HardTerm架构



## 各模块细节

### 基础头文件

* Base：定义了所有的基础类型、常数、函数
* Show：定义了渲染器所需的格式化toString函数

### CPU模块

* IF取指
* ID译码
* EX执行
* MEM访存
* Reg（RB）
* 触发器（ID_IF IF_ID ID_EX EX_MEM）
* Ctrl
* 中断的实现

### IO模块（RamUartCtrl）

协调处理所有的IO请求。

控制的设备接口：

* RAM1
* RAM2
* 串口1
* 串口2
* 1个数据缓冲区

接受的IO请求接口：（优先级依次递减）

* Boot模块：写RAM2（指令区）
* CPU的MEM模块：读写RAM1/RAM2/串口1/串口2/数据缓冲区
* CPU的IF模块：读RAM2（指令区）
* Renderer模块：读RAM1（显存区）

限于CPU要求在1个周期内完成 [提出请求-访存-拿到结果] 的全过程，因此模块主体是纯组合逻辑，写信号的下拉操作利用时钟信号后半周期完成。唯一涉及的时序逻辑是读串口时会强行延迟20周期。

#### 内存地址映射

* BF00/BF01：串口1 数据/标志
* BF02/BF03：串口2 数据/标志
* BF04/BF05：缓冲区 数据/标志
* E000-FFFF：显存区

### Renderer模块

控制屏幕显示内容。输入VGA正在显示的像素坐标，输出像素颜色。纯组合逻辑。

### HardTerm模块

### 其它辅助模块

* vga_controller：开源代码。生成VGA控制信号和当前屏幕坐标。
* ps2_keyboard_to_ascii：开源代码。将PS2信号解码为按键信号和ASCII码。
* uart：提供代码。将串口2信号转化为和串口1相同的格式。
* Boot：读取Flash并告知IO模块当前要写RAM2的地址和数据
* DataBuffer：数据缓冲区，提供读写接口（信号格式同RAM）
* Shell：一种特殊的DataBuffer，有两个写接口，额外支持退格和回车
* AsciiToBufferInput：将ASCII信号转化为Buffer写信号
* FontReader：从片内ROM中读取字体点阵数据
* PixelReader：将像素块坐标转化为RAM1地址，委托IO模块读取显存

## 进程·问题·优化·妥协

![TimeTable](./TimeTable.png)

第9周周日，第一版VGA。VGA引脚反了，调了一小时。

![FirstVGA](./FirstVGA.jpg)

第10周周四，在仿真中跑出OK。

![FirstSimOK](./FirstSimOK.jpg)

第10周周日，第一版调试信息界面，可以板上输出OK。

![FirstDebugUI](./FirstDebugUI.jpeg)

第11周周三，监控程序跑通，25MHz性能测试。

![TermTest](./TermTest.jpeg)

第12周周日，生命游戏，显示汉字。

![GameOfLife](./GameOfLife.gif)

![奋战三星期造台计算机](./奋战三星期造台计算机.jpeg)

