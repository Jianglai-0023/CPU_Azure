# Toy CPU Azure

## 设计草稿📝
![assign](https://github.com/Jianglai-0023/CPU_Azure/blob/main/README.assets/IMG_1669.jpg)
## 功能模块 todolist🧩
- [x] IF
- [x] IC
- [x] MemCtrl
- [x] RegFile
- [x] Decode
- [x] ROB
- [x] RS
- [x] LSB
- [x] ALU
- [x] line
## 功能描述🏂
* instruction 从Ifetch中取出，到达Decoder，Decoder解析并发送给ROB，ROB将结果再发送给RS与LSB，并附上ROB's order。
## 问题💡
* 输出信号的同时一定要输出一个flag代表当前值有效吗？虽然这样做比较保险的样子，在没有很明白的时候先这样实现
* (from LSB) 如何处理多个模块同时调用memctrl的问题?

## Data Point🐾
- [x] 005

## Jornal🗓
2022/12/2 初步完成全部连线以及各模块功能代码 💁🏻
2022/12/13 开始调IF部分
2022/12/14 还是IF部分，增加bc操作
2022/12/17 重构了ROB，LSB，RS之间的关系
2022/12/23 first passed

## Problem Record❗️
* 需要对各模块进行initial操作
* 还是Eclipse好用,除了操作比较诡异
* 对于现有的branch采取halt处理，在ROB commit结果后解除halt状态
* ALU负责广播并更新ROB/RS/LSB中的ready值，ROB负责更新regfile以及LSB中STORE指令
* ic_flag一直是true，导致两个指令衔接的空档周期也会读入指令，产生错误
* S指令不需要放入ROB与RS中
* L指令需要放入ROB，不需要放入RS中
* initial块的作用与rst情况等价
**跳转错误时**
信号由ROB即将commit branch指令时发出：
* 清空ROB
* 清空branch下的LSB
* 清空RS
* 修改pc

## IF
* 当前pc得到具体ins之后才会有下一条pc，IC会在返回ins的时候将flag设为True，且只能维持一个clk，否则pc可能多跳