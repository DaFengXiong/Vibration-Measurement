# Vibration-Measurement

用于检测视频中微小振动物体的振动频率，振幅，可检测亚像素级振动。振动检测结果可用于**运动方法**、**结构健康检测**、**模态分析**等。

### 使用说明
1. 数据预处理
    - 振动视频数据，可使用任何可录制视频的设备拍摄；
    - 所摄振动结构视频，需要将其首先采样到较小分辨率，但不要改变原始宽高比，300~500的像素宽高比较合适；
    - 本项目`data\振动台\`目录下的视频数据，使用 `Gpro Hero` 拍摄振动台拍摄得到，后经格式工厂裁剪缩放得到。数据命名格式为`GOPRO840_aa_bb`，其中`aa`表示振动台预设振动频率，其中`bb`表示振动台预设振动幅度。
2. 调用代码
    - 调用示例：`Vibration_measure('./data/振动台/GOPR0831_37.mp4',1,14,2,'y');`
3. 手动选择像素点
    ![具有较大振动的像素点](./data/images/1.jpg)
    程序会自动给出具有较大振幅的像素点，请根据图示，在其中选择一个处在振动物体边沿上的像素点，记录其像素坐标。例如对于`GOPR0831_37.mp4`可选像素坐标（261,161）。在`Vibration_measure.m`的252行下，将像素坐标填入相应位置。再次执行`Vibration_measure('./data/振动台/GOPR0831_37.mp4',1,14,2,'y');`

4. 结果分析
    - 幅频图
    ![幅频图](./data/images/2.jpg)
    - 振幅随时间变化
    ![振幅随时间变化](./data/images/3.jpg)
    - 振幅随帧数变化
    ![振幅随时间变化](./data/images/4.jpg)
5. 奈奎斯特采样频率
    - 视频采集帧率应该大于振动频率的2倍，才可能实现测量。
