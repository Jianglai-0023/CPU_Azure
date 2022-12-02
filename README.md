# CPU_Azure

## 一、设计草稿📝
![assign](https://github.com/Jianglai-0023/CPU_Azure/blob/main/README.assets/IMG_1669.jpg)
## 功能模块🧩
-[x] IF
-[x] IC
-[x] MemCtrl
-[x] RegFile
-[x] Decode
-[x] ROB
-[x] RS
-[x] LSB
-[x] ALU
-[x] line
## 功能描述🏂
* instruction 从Ifetch中取出，到达Decoder，Decoder解析并发送给ROB，ROB将结果再发送给RS与LSB，并附上ROB's order。
## 问题💡
* 输出信号的同时一定要输出一个flag代表当前值有效吗？虽然这样做比较保险的样子，在没有很明白的时候先这样实现
* (from LSB) 如何处理多个模块同时调用memctrl的问题?

## jornal🗓
12/2 初步完成全部连线以及各模块功能代码💁🏻