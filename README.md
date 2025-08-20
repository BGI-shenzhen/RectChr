# RectChr
Multi-level visualization of genomic statistical variables on rectangular chromosomes

###  1 Introduction
<b>RectChr</b> 主要用于基于Chr染色体水平上<b>多层次</b>的可视工具，对一些统计变量用<b> 点,形状，线，柱状和heatmap、高亮，文本文字，彩虹链接, 泛连接，自链接,动态heatmap,动态hist,山脊线</b>以及<b>结合颜色</b>【即线，散点，直方图，热图,文本, line, scatter/point,shape, histogram , PairWiseLink，link.LinkS,heatmapAnimated,histAnimated, heatmap(highlights)和text, ridgeline 】等 可视化各chr上各区域这个统计量，达到快速一眼看出规律，识别结果。  并且各种可以自己组合  自由修改相关参数，使用方法极像circos的一样。
</br>简单点说 <b>[circos](http://circos.ca/)  </b>可以画的，<b>这儿均可以画，只是把圈圈图改为长方型的</b>。其中自己搭配层颜色等，同时也比circos多了一些默认配置，用起来十分简单，如SNP GC密度 直接输入文件即可。
</br> 可以画遗传图谱,binmap,基因组共线性，GC分布，群体遗传等选择区域，GWAS等等图.程序仅提供11实例.
</br>
</br>程序是给一些有基础的生信朋友用的，若是小白看不懂就算了。
</br>
</br><b>RectChr</b> is mainly used for muti-Level visualization tools based on the Chr chromosome level. It uses<b>  points,shape, lines, histogram and heatmap, highlighting, text, link,LinkS,heatmapAnimated,histAnimated and PairWiseLink,ridgeline</b> combined <b>colors</b> for some statistical variables [line, scatter, histogram, heatmap, text , line, scatter/point, histogram, PairWiseLink, link,LinkS, heatmap (highlights) and text,ridgeline,heatmapAnimated,histAnimated] and so on to visualize the statistics of each area on each chr, so as to quickly see the pattern and recognize the results at a glance. And various parameters can be combined freely to modify related parameters, and the usage method is very similar to circos.
</br>To put it simply,  <b>[circos](http://circos.ca/)  </b>can be drawn, and all can be drawn here，but <b>the circle diagram is changed to a rectangular shape</b>. Among them, the color of the layer is matched by itself. At the same time, there are some more default configurations than circos, which is very simple to use, such as SNP GC density and input the file directly.
</br>You can draw genetic maps, binmaps, genome collinearity, GC distribution, population genetics and other selected regions, GWAS, etc. The program only provides 11 examples.



###  2 Download and Install
------------
The <b>new version</b> will be updated and maintained in <b>[hewm2008/RectChr](https://github.com/hewm2008/RectChr)</b>, please click below website to download the latest version
</br><p align="center"><b>[hewm2008/RectChr](https://github.com/hewm2008/RectChr)</b></p>

<b> 2.1. linux/MaxOS&nbsp;&nbsp;&nbsp;   [Download](https://github.com/hewm2008/RectChr/archive/v1.38.tar.gz)</b>
  
  </br> <b>2.2 Pre-install</b>
  </br> RectChr is for Linux/Unix/macOS only. Before installing,please make sure the following pre-requirements are ready to use.
  </br> 1) [Perl](https://www.perl.org/) with the [SVG.pm](https://metacpan.org/release/SVG) in Perl should be installed. SVG is not necessary,We have provided a built-in SVG module in the package.
  </br> 2) [convert](https://linux.die.net/man/1/convert) command is recommended to be pre-installed, although it is not required

</br> <b>2.3 Install</b>
</br> Users can install it with the following options:
</br> Option 1: 
<pre>
        git clone https://github.com/hewm2008/RectChr.git
        cd RectChr;	chmod 755 -R bin/*
        ./bin/RectChr  -h 
</pre>


###  3 Parameter description
------------
</br><b>3.1 RectChr</b>
</br><b>3.1.1 Main parameter</b>

```php
        Usage: RectChr  -InConfi  in.cofi -OutPut OUT

                -InConfi      <s> : InPut Configuration File
                -OutPut       <s> : OutPut svg file result

                -help               See more help *Manual.pdf
                                    [hewm2008 v1.38]

```
</br> brief description for function:
<pre>
	   # 用法和circos相似，主要一个配置文件一样,具体见pdf，简要功能介绍如下
	   1） chr可以横放or纵放，间隙和高度均可以自己定义
	   2） 各chr中可以定义多层，各层可以用不同的画图展示方式。
	   3） 画图方式 共有12种，分别是线，点，柱状，泛链接，自链接，彩虹链接，热度高亮和文本文档 [line, scatter/point, histogram , PairWiseLink，link,LinkS， heatmap(highlights)和text等]
	   4)  颜色渐变(ColorBrewer)和等分等均可以自己修改，数据可以限高低
	   5)  开放所有参数，可以自我修改细节等
	   6)  ...
	   
</pre>

</br><b>3.1.2 Other parameters</b>
```php
     输入文件格式见  pdf.主要为chr start end Value1 ... 的格式
```

</br><b>3.2.2 Detail parameters</b>
```php
	#  具体见pdf
SetParaFor = global

File1  = ./scaf2chr.format2             ##  这个是必须输入参数，并且尽量放在最前,格式为[Chr Start End Value1 Value2 ... ValueN]
                       ##  其中用NA表示不画，chr End End NA不画但End可以用来贝记为chr的长度
#ValueX = 2             ##  多少层，类同circos多少个圈，这不设默认是N,即根据File1的格式来的，可以自己设
#ChrSpacingRatio =0.2  ##  不同染色体chr之间的间隔比例(ChrWidth*ChrSpacingRatio)
#Main = "Scaf2Chr"  ##  the Figtur Name: MainRatioFontSize MainCor ShiftMainX  ShiftMainY 
#ColorsConf = col.file ##  通过在主配置文件 input 自定义颜色和 Value的对应关系;( P1 = "#FE0808" )
#ChrArrayDirection = vertical  ##  horizontal/vertical  chr是按纵排列还是横排列
##其它当很少用到的参数 BGChrEndCurve=1/ 等等

################################ Figure ############################################################



##############################     画布 和 图片 参数配置 #################################
#Chromosomes_order =   ## chr的顺序和只列某些chr出来画，若没有配置，程序会按chr名自动排序 chr1,chr2,chr3
#ZoomRegion           ## Zoom the specific Region,format (ZoomRegion=chr2:1000:5000)
#body=1200   ##   默认是1200，主画布大小设置  另外：up/down/left/right) = (55,25,100,120);  #CanvasHeightRitao=1.0 CanvasWidthRitao=1.0
#RotatePng   = 90  ##  对Figure进行旋转的角度
#RotateChrName  = -90  ##  旋转chr名字 text
#ChrSpacingRatio=0.2    ##  不同染色体chr之间的间隔比例(Sum(ChrWidthX*X)*ChrSpacingRatio)



######    默认各层的配置参数 若各层没有配置的会，则会用这儿的参数 ######

SetParaFor = LevelALL  ##  下面是处理初始化参数 SetParaFor 参数处理,若为 LevelALL，即先为所有层设置的默认值
#File2    =             ##  可以输入别的文件
PType  = heatmap       ##  线，散点，直方图，热图,文本, line, scatter, histogram ， heatmap(highlights)和text,shape等等
#ShowColumn =          ##  若SetParaFor为LevelALL时，N层的ShowColumn默认为File1的第ValueN所的Column(N+3)
                       ##  参数格式可以设为 ShowColumn=File1:4 File2:4,5
                       ##  File2:4,5 表示file1的第四和第五列用heatmap表示
#crBG="#B8B8B8"         ##  此层(ValueX)背景色  的配色
#TopVHigh=0.95          ##  此层Top of ValueX 用最高点颜色[0.95],其它再等分
#TopVLow=0              ##  此层Top of ValueX 用最低点颜色[0],其它再等分
##YMax=                 ##  设置此层(ValueX)的最大值,默认自动
##YMin=                 ##  设置此层(ValueX)的最小值,默认自动
##LimitYMax/LimitYMin   ##  超过某个值就附为此值
#Gradien=10             ##  此层(ValueX)多少等分颜色
#ChrWidth=20            ##  此层(ValueX)在画布的宽度
#BGWidthRatio =1        ##  此层(ValueX)的背景(backgroup)的宽度默认和ChrWidth一样(0-1])
#LogP=0                 ##  此层(ValueX)不作 0-log10(Value) 处理
#ValueSpacingRatio=0    ##  同一染色体中此层(ValueX)之间的间隔比例(ChrWidth*ValueSpacingRatio)
#SizeGradienRatio=  ##设置渐变条的大小
#NoShowGradien=0        ##  若要不显示渐变条  可设为1
#ShowYaxis=0             ##  是否显示所有层的Y axis的起终点值,默认值此:0 不显示

########   更多配置的参数  可以自己设，没有的话会自动设置  #######
##Rotate/fill/Cutline/strokewidth/stroke//font-size/font-family/fill-opacity/strokeWidthBG/crStrokeBG/NoShowBackGroup   ### 等等
##ShiftGradienX=0 ## 渐变条左右移动   ##ShiftGradienY=0  ## 渐变条上下移动
##ShiftChrNameX=0/ShiftChrNameY=0   ## chrName移动  ChrNameRatio=1.0
#text-font-size   TextFontRatio=1.0

##  LevelName = "Name"  ##  the Level Name  :NameRatioFontSize NameCol ShiftNameX  ShiftNameY  NameRotate

#ColorBrewer=           ## 颜色配色画板 即不起作用。数值 : GnYlRd; Text为：Paired, see more RColorBrewer
#crBegin="#006400"      ##  此层(ValueX)最低值Value 的配色
#crMid="#FFFF00"        ##  此层(ValueX)中间值Value 的配色
#crEnd="#FF0000"        ##  此层(ValueX)最大值Value 的配色
....  #等等


```

</br><b>3.3 Output files</b>
<pre>
out.svg: Output plot in SVG format
out.png: Output plot in png format
</pre>


###  4 Example
------------

</br>See more detailed usage in the&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <b>[Chinese Documentation](https://github.com/hewm2008/RectChr/blob/main/类circos功能的RectChr_Manual_Chinese.pdf)</b>
</br>See more detailed usage in the&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <b>[English Documentation](https://github.com/hewm2008/RectChr/blob/main/类circos功能的RectChr_Manual_Chinese.pdf)</b>
</br>See the example directory and  Manual.pdf for more detail.
</br>具体见这儿  Manual.pdf for more detail 里面的实例和配置，后期将在某些网址释放一些教程
</br></br> 
../../bin/RectChr       -InConfi        in.cofi -OutPut OUT
</br>  目录  Example/example*/　里面有输入和输出和脚本用法。


* Example 1) Sca2chr 示意结果图
如下主要画两层    text 和 highlight（高亮）两种配合 ， 然后旋转一下。
![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example1/OUT.png)

* Example 2) 遗传图谱+maker 
两层  即 画text 层和 高亮层两种配合。   其中高亮层的背色条宽度缩小了点.
![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example2/OUT.png)


* Example 3)某一变量的分布图
一层， 用户可以结果数据(可以是不是数字)用point高低 柱状图 和lines及结合颜色来

![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example3/OUT.png)


* Example 4)  BinMap+maker的分布图
两层  都是高亮层两种配合
![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example4/OUT.png)


* Example 5)  群体遗传变量+受选择区域
多层 多种画图方式
![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example5/OUT.png)
![out2.png](https://github.com/hewm2008/RectChr/blob/main/Example/example5/OUT2.png)


* Example 6) 多个基因组的共线性图 
两层 link和其它画图方式结合。可以横放chr 和纵排
![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example6/OUT1.png)

![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example6/OUT4.png)

![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example6/OUT5.png)


* Example 7) 区域link（关联彩虹图）
 两层,彩虹链接和其它画图方式结合

![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example7/OUT.png)
![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example7/OUT2.png)


* Example 8) GWAS的图
两层上层为点图，层高度调高点; 下层为chr啥都不画仅背影条(可以其它画图方式)，主要说明可以横放chr
![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example8/OUT.png)
![out2.png](https://github.com/hewm2008/RectChr/blob/main/Example/example8/OUT2.png)
![out4.png](https://github.com/hewm2008/RectChr/blob/main/Example/example8/OUT4.png)

* Example 9) binMap的图
多层heatmap，横放chr
![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example9/OUT.png)

* Example 10) 动态热度图和动态柱状图
某一层为动态svg,须要下载svg到本地，用较新的浏览器打开即可，别外可以用其它软件将svg转为gif格式

* Example 11) shape的一个展示
![out.png](https://github.com/hewm2008/RectChr/blob/main/Example/example11/OUT.png)




###  5 Advantages

</br>速度快，少内存
</br>可以自我定义组合多层次
</br>有perl即可以运行，免安装


###  6 An example image generated by RectChr.
------------

</br>具体实际见程序目录里面的Example/example* 
</br>在这搜索了一些在网上的其它人的配置和示意,点击可以找开网页，查看
</br> &nbsp;[RectChr总简介](https://zhuanlan.zhihu.com/p/352026153)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之 两个群体比较 之 受择选信号+选择区域](https://zhuanlan.zhihu.com/p/352900660)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之一个群体遗传多态](https://zhuanlan.zhihu.com/p/352886319)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之几种方法受选择区域](https://zhuanlan.zhihu.com/p/352798284)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之 两个群体比较 之 受择选信号+选择区域 横放chr ](https://zhuanlan.zhihu.com/p/353999839)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之 群体sweep +QTLS+IBD作图](https://zhuanlan.zhihu.com/p/366244372)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之 两个基因组共线性分析](https://zhuanlan.zhihu.com/p/354274078)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之 多个基因组(3或更多)共线性分析](https://zhuanlan.zhihu.com/p/361324138)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之 多样品某一区域 genotype/gene/单倍型 热度图](https://zhuanlan.zhihu.com/p/358342096)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之 多样品多区域 binmap 热度图](https://zhuanlan.zhihu.com/p/360097194)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之 动态heatmap和动态柱状图 svg](https://zhuanlan.zhihu.com/p/362705487)
</br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[RectChr之 高级感的GWAS曼哈顿图](https://zhuanlan.zhihu.com/p/375048543)


###  7 Discussing
------------
- [:email:](https://github.com/hewm2008/RectChr) hewm2008@gmail.com / hewm2008@qq.com
- join the<b><i> QQ Group : 125293663</b></i>

######################swimming in the sky and flying in the sea #############################

