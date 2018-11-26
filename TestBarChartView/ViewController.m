//
//  ViewController.m
//  TestBarChartView
//
//  Created by Summer on 2018/11/26.
//  Copyright © 2018 Summer. All rights reserved.
//

#import "ViewController.h"
#import <Charts/Charts-Swift.h>
#import <Masonry/Masonry.h>

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]


@interface ViewController ()<ChartViewDelegate>
@property (nonatomic , strong)  BarChartView *chartView;
@property (nonatomic , strong)  BarChartData  *chartData;
@property (nonatomic , strong) NSArray *numbers;
@property (nonatomic , strong)  NSArray *names;
@property (nonatomic , assign) BOOL isHorizontal;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:@"设置为横向条形统计图" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(respondsToButton:) forControlEvents:UIControlEventTouchUpInside
     ];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-20);
    }];
    /*  为饼状图提供数据 */
    _numbers = @[@"10",@"20",@"30",@"400"];
    _names = @[@"情况1",@"情况2",@"情况3",@"情况4"];
    [self respondsToButton:button];
}

- (void)respondsToButton:(UIButton *)sender{
    sender.selected = !sender.selected;
    [sender setTitle:sender.selected == YES ? @"设置为竖状条形统计图" :@"设置为横向条形统计图" forState:UIControlStateNormal];
    self.isHorizontal = sender.selected;
    [self setBarUI];
    [self setBarData];
}

- (void)setBarUI{
    if (self.chartView) {
        [self.chartView removeFromSuperview];
    }
    if (self.isHorizontal) {
        HorizontalBarChartView *chartView = [[HorizontalBarChartView alloc]init];
        _chartView = chartView;
    }else{
        BarChartView *chartView = [[BarChartView alloc]init];
        _chartView = chartView;
    }
    [self.view addSubview:_chartView];
    [self.chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.chartView.superview.mas_centerY);
        make.left.equalTo(self.chartView.superview).offset(10);
        make.right.equalTo(self.chartView.superview).offset(-10);
        
        
        make.height.equalTo(self.chartView.mas_width);
    }];
    
    /* 基本样式 */
    _chartView.delegate = self;//设置代理
    [_chartView setExtraOffsetsWithLeft:5.f top:5.f right:40.f bottom:5.f];//条形图距离边缘的间隙
    _chartView.drawGridBackgroundEnabled = YES;//是否绘制网状格局背景(灰色那一块)
    _chartView.drawValueAboveBarEnabled = YES; //是否在条形图顶端显示数值
    _chartView.extraBottomOffset = 0;//距离底部的额外偏移
    _chartView.extraTopOffset = 0;//距离顶部的额外偏移
    _chartView.fitBars = YES;//统计图完全显示
    
    
    /* X 轴 */
    ChartXAxis *xAxis =  _chartView.xAxis;
    xAxis.axisLineWidth = 1;//设置X轴线宽
    xAxis.axisLineColor = [UIColor redColor];//设置X轴线颜色
    xAxis.drawGridLinesEnabled = NO;//不绘制网格线（X轴就绘制竖线，Y轴绘制横线）
    xAxis.labelPosition = XAxisLabelPositionBottom;//X轴label在底部显示
    xAxis.labelFont = [UIFont systemFontOfSize:13];//X轴label文字大小
    xAxis.labelTextColor = UIColorFromHex(0x515254);//X轴label文字颜色
    
    
    /* 左边 Y轴 */
    
    ChartYAxis *leftAxis =  _chartView.leftAxis;
    leftAxis.axisMinimum = 0;//Y轴最小值（不然不会从0开始）
    leftAxis.forceLabelsEnabled = NO;//不强制绘制制定数量的label
    leftAxis.inverted = NO;//是否将Y轴进行上下翻转
    leftAxis.axisLineWidth = 0.5;//Y轴线宽
    leftAxis.axisLineColor = [UIColor redColor];//Y轴颜色
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;//Y轴label位置
    leftAxis.labelTextColor = [UIColor blueColor];//Y轴文字颜色
    leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];//Y轴文字字体
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    numberFormatter.positiveSuffix = @" 小时";//正数时的后缀
    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:numberFormatter];//Y轴文字描述单位
    
    /*网格线样式*/
    leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];//设置Y轴虚线样式的网格线
    leftAxis.gridColor = [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];//Y轴网格线颜色
    leftAxis.gridAntialiasEnabled = YES;//开启Y轴锯齿线
    
    /*极限值*/
    ChartLimitLine *limitLine = [[ChartLimitLine alloc] initWithLimit:80 label:@"极限值"];
    limitLine.lineWidth = 2;//极限值的线宽
    limitLine.lineColor = [UIColor greenColor];;//极限值的颜色
    limitLine.lineDashLengths = @[@5.0f, @5.0f];//极限值的样式
    limitLine.labelPosition = ChartLimitLabelPositionLeftTop;;//极限值的位置
    [leftAxis addLimitLine:limitLine];//添加到Y轴上
    leftAxis.drawLimitLinesBehindDataEnabled = YES;//设置极限值线绘制在柱形图的后面
    
    /* 右边 Y轴 */
    ChartYAxis *rightAxis =  _chartView.rightAxis;
    rightAxis.enabled = NO; //隐藏右边轴
    
    
    /*空数据的显示*/
    _chartView.noDataTextColor = UIColorFromHex(0x21B7EF);//没有数据时的文字颜色
    _chartView.noDataFont = [UIFont systemFontOfSize:15]; //没有数据时的文字字体
    _chartView.noDataText = @"暂无数据";//没有数据是显示的文字说明
    
    
    /* 统计图的名字*/
    _chartView.chartDescription.text = @"工时统计图";//统计图名字
    _chartView.chartDescription.enabled = YES;//是否显示统计图
    _chartView.chartDescription.textColor = [UIColor redColor];//统计图名字颜色
    _chartView.chartDescription.textAlign = NSTextAlignmentLeft;//统计图名字对齐方式
    if (self.isHorizontal) {
        _chartView.chartDescription.xOffset = 50;
        _chartView.chartDescription.yOffset = -10;
    }else{
        _chartView.chartDescription.xOffset = 50;
        _chartView.chartDescription.yOffset = -30;
    }
    
    /* 设置图例样式 */
    _chartView.legend.enabled = YES;//显示饼状图图例解释说明
    _chartView.legend.maxSizePercent = 0.1;///图例在饼状图中的大小占比, 这会影响图例的宽高
    _chartView.legend.formToTextSpace = 10;//图示和文字的间隔
    _chartView.legend.font = [UIFont systemFontOfSize:10];//图例字体大小
    _chartView.legend.textColor = [UIColor blackColor];//图例字体颜色
    _chartView.legend.form = ChartLegendFormSquare;//图示样式: 方形、线条、圆形
    _chartView.legend.formSize = 5;//图示大小
    _chartView.legend.yOffset = 5;
    
    
    /* 统计图的交互*/
    _chartView.pinchZoomEnabled = YES;//x、y轴捏合缩放
    _chartView.scaleYEnabled = YES;//Y轴缩放
    _chartView.doubleTapToZoomEnabled = NO;//取消双击缩放
    _chartView.dragEnabled = YES;//启用拖拽图表
    _chartView.dragDecelerationEnabled = YES;//拖拽后是否有惯性效果
    _chartView.dragDecelerationFrictionCoef = 0.9;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
    
}

- (void)setBarData{
    double barWidth = 0.5f;
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < _numbers.count; i++){
        /*
         x : x 轴的第几个值
         y : 对应 x 轴的 y 值
         data : 标识
         
         */
        [yVals addObject:[[BarChartDataEntry alloc] initWithX:i y:[_numbers[i] doubleValue] data:[NSString stringWithFormat:@"%d",i]]];
    }
    
    /*
     values : yVals数组
     label : 图例名字
     
     */
    BarChartDataSet *set = [[BarChartDataSet alloc] initWithValues:yVals label:@"我是图例"];
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObject:UIColorFromHex(0x96B5D4)];
    //    [colors addObject:UIColorFromHex(0xF27655)];
    //    [colors addObject:UIColorFromHex(0x7ECBC3)];
    //    [colors addObject:UIColorFromHex(0x8ACDA2)];
    set.colors = colors;//统计图颜色,有几个颜色，图例就会显示几个标识
    
    set.drawValuesEnabled = YES;//是否在柱形图上面显示数值
    set.highlightEnabled = YES;//点击选中柱形图是否有高亮效果，（双击空白处取消选中）
    
    BarChartData *data = [[BarChartData alloc] initWithDataSet:set];
    data.barWidth = barWidth; //统计图宽占X轴的比例
    
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    numFormatter.numberStyle = NSNumberFormatterDecimalStyle;//小数点形式
    numFormatter.maximumFractionDigits = 2; // 小数位最多位数
    //    numFormatter.negativeSuffix = @" 小时";//负数的后缀
    numFormatter.positiveSuffix = @" 小时";//正数的后缀
    ChartDefaultValueFormatter *formatter = [[ChartDefaultValueFormatter alloc] initWithFormatter:numFormatter];
    [data setValueFormatter:formatter];// 更改柱状显示格式
    [data setValueFont:[UIFont systemFontOfSize:13]];// 更改柱状字体显示大小
    [data setValueTextColor:UIColorFromHex(0x515254)];// 更改柱状字体颜色
    
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelCount = _names.count;//X轴文字描述的个数
    xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] initWithValues:_names];//X轴文字描述的内容
    
    _chartView.data = data;
    
    
    //设置动画效果，可以设置X轴和Y轴的动画效果
    [self.chartView animateWithYAxisDuration:2.0f];
}

- (void)chartValueSelected:(ChartViewBase *)chartView entry:(ChartDataEntry *)entry highlight:(ChartHighlight *)highlight{
    NSLog(@"chartValueSelected");
    //当前选中饼状图的值
    NSLog(@"---chartValueSelected---value: x = %g,y = %g",entry.x,  entry.y);
    //当前选中饼状图的index
    NSLog(@"---chartValueSelected---value:第 %@ 个数据", entry.data);
}



@end
