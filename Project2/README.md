# Project2

## 开发说明

### 命令行工具 nvc

查看命令说明：`nvc -h`

常用命令：

```
nvc -a *.vhd
nvc -e <entityname>
nvc -r <entityname> -w
```

编译产生的中间文件默认在`work`文件夹中

我已经写好了一份Makefile，大概用法如下：

* `make`: 编译
* `make testalu`: 运行ALU模块测试
* `make clean`: 清理

运行测试后，可在终端查看结果，还会自动生成波形文件`*.fst`，可用`GtkWave`打开查看。

### 测试的写法

一个样例见`test_alu.vhd`

### 包

`base.vhd`中定义了一个叫`base`的package。

所有全局的常量，函数，类型都定义在这里。

使用时在文件最上面加入：`use work.Base.all;`

由于存在依赖，编译时这个文件一定要第一个编译（见makefile）