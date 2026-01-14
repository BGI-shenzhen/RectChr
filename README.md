# RectChr
Multi-level visualization of genomic statistical variables on rectangular chromosomes

###  1 Introduction
RectChr 是一款聚焦于染色体（Chr）水平的多层次可视化工具。它借助丰富多样的可视化元素,包括点、形状、线、柱状图、热图、高亮显示、文本、彩虹链接、自连接、动态热图、动态直方图、山脊线等,并巧妙结合颜色运用<b>【点(scatter/point)、形状(shape)、线(line)、柱状图(histogram)、热图(heatmap/highlights)、高亮显示(heatmap/highlights)、文本(text)、山脊线(ridgeline) 、彩虹链接(PairWiseLink)、自连接(LinkS)、动态热图(heatmapAnimated)、动态直方图(histAnimated)形式】</b>,对各类统计变量进行直观呈现,从而实现对各染色体上不同区域统计量的可视化展示。用户能够通过这一工具,快速且直观地洞察数据规律、识别分析结果。
</br></br>该工具的一大显著优势在于其高度的灵活性。用户可以根据自身需求自由组合各种可视化元素,并对相关参数进行自主修改。其使用方式与经典的 <b>[circos](http://circos.ca/)</b> 工具极为相似,但又有所创新。circos 能够实现的可视化效果,RectChr 同样可以达成,不同之处在于 RectChr 将传统的圈圈图形式转变为长方形（既可以横向放置,也能纵向排列）。除此之外,用户还能自行搭配各层颜色等样式。简单点说 circos 可以画的,这儿均可以画,只是把圈圈图改为长方型的(可横放可纵排) 
</br>不仅如此,RectChr 还提供了一些默认配置,进一步简化了使用流程。例如,在处理 SNP GC 密度这类常见分析时,用户只需直接输入相关文件,就能轻松完成可视化操作,真正做到了简单易用。
</br>
</br>程序是给一些有基础的生信朋友用的,若是小白看不懂就算了。

</br> </br>RectChr is a multi-level visualization tool that focuses on the chromosome (Chr) level. It uses a wide variety of visualization elements, including points, shapes, lines, histograms, heatmaps, highlights, text, rainbow links, self-links, dynamic heatmaps, dynamic histograms, ridgelines, etc., and cleverly combines colors to use<b> [scatter/point, shape, line] (line), histogram, heatmap/highlights, heatmap /highlights), text, ridgeline, PairWiseLink, self-connect (LinkS), heatmapAnimated, and histAnimated] </b>, which visually presents various statistical variables, so as to realize the visual display of statistics in different regions on each chromosome. Users can quickly and intuitively gain insight into data patterns and identify analysis results through this tool. 
</br>One of the significant advantages of this tool is its high degree of flexibility. Users can freely combine various visualization elements according to their own needs and modify relevant parameters independently. Its use is the same as the classic <b>[circos](http://circos.ca/)</b> The tools are very similar, but innovative. Circos enables visualization,RectChr This can also be achieved, except that RectChr transforms the traditional circle chart form into a rectangle (which can be placed horizontally or vertically). In addition, users can also match the colors and other styles of each layer by themselves.To put it simply circos Anything that can be drawn can be drawn here, but the circle diagram is changed to a rectangle(Can be placed horizontally or vertically.)) 
</br>Not only that, but RectChr also provides some default configurations that further simplify the usage process. For example, when dealing with common analyses such as SNP GC density, users can easily visualize it by simply entering the relevant files, making it truly easy to use. 

![intro.png](https://github.com/hewm2008/RectChr/blob/main/info/intro.png)

###  2 Download and Install
------------
The <b>new version</b> will be updated and maintained in <b>[hewm2008/RectChr](https://github.com/hewm2008/RectChr)</b>, please click below website to download the latest version
</br><p align="center"><b>[hewm2008/RectChr](https://github.com/hewm2008/RectChr)</b></p>

<b> 2.1. linux/MaxOS&nbsp;&nbsp;&nbsp;   [Download](https://github.com/hewm2008/RectChr/archive/v1.43.tar.gz)</b>
  
  </br> <b>2.2 Pre-install</b>
  </br> RectChr is for Linux/Unix/macOS only. Before installing,please make sure the following pre-requirements are ready to use.
  </br> 1) [Perl](https://www.perl.org/) with the [SVG.pm](https://metacpan.org/release/SVG) in Perl should be installed. SVG is not necessary,We have provided a built-in SVG module in the package.
  </br> 2) [convert](https://linux.die.net/man/1/convert) command is recommended to be pre-installed, although it is not required

</br> <b>2.3 Install</b>
</br> Users can install it with the following options:
<pre>
        git clone https://github.com/hewm2008/RectChr.git
        cd RectChr;	chmod -R 755 bin/*
        ./bin/RectChr  -h 
</pre>


###  3 Parameter description
------------
</br><b>3.1 RectChr</b>
</br><b>3.1.1 Main parameter</b>

```php
        Usage: RectChr  -InConf  in.conf  -OutPut OUT

                -InConf       <s> : Input Configuration File
                -OutPut       <s> : OutPut svg file result

                -help               See more help *Manual.pdf
                                    [hewm2008 v1.43]

```
</br> brief description for function:
<pre>
	# RectChr has rich and flexible visualization capabilities, and here is a brief description of its features:
1) Chromosome layout customization: You can freely set the placement direction (chr_orientation) and order (chr_order) of chromosomes, and you can choose horizontal or vertical orientation. At the same time, you can also define the gap between chromosomes (padding_ratio), the height of each layer (track_height), and the background color (background_color).
2) Multi-layer drawing structure: Each chromosome can define a multi-layer structure, the number of layers is determined by track_num (level), and each layer can be displayed in different drawing methods.
3) Diverse drawing methods: 12 drawing types (plot_type are available), including scatter/point, shape, line, histogram, heatmap, highlights, text, ridgeline, PairWiseLink, LinkS, HeatmapAnimated and histAnimated to meet different visualization needs.
4) Color and Data Range Adjustments: Supports custom modifications to color artboards (such as colormap_brewer_name), color gradients, and aliquots (colormap_nlevels). At the same time, the range of data can be limited, for example by  parameters such as YMax, upper_outlier_ratio, cap_max_value, etc.
5) Unified input format: The input format is unified, and it is very easy to specify statistics, such as show_columns = File2:4, where the first three columns represent the region, and File2:4 uses the fourth column of the second file as the graphing statistics.
6) Area Magnification Function: Using the chr_zoom_region parameter, it can realize the function of zooming in to view specific areas, making it easy to focus on details.
7) Open customization of parameters: All parameters are open to the public, and users can modify the details according to their needs.
8) ...
</pre>

</br><b>3.1.2 InPut files</b>
Data frame format. The input file format is shown in pdf. The format is mainly fixed for the first three columns: 
```php
     chr start end Flag1 Flag2 ... 
```

</br><b>3.2.2 Detail parameters</b>
For a list and description of all parameters, see the file [NewParaList.xlsx](https://github.com/hewm2008/RectChr/blob/main/NewParaList.xlsx). Below is a diagram of the parameters and controls.
![para.png](https://github.com/hewm2008/RectChr/blob/main/info/para.png)

</br>See the example directory and  Manual.pdf for more detail.
</br>See more detailed usage in the&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <b>[Chinese Documentation](https://github.com/hewm2008/RectChr/blob/main/RectChr_manual_Chinese_251006.pdf)</b>
</br>See more detailed usage in the&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <b>[English Documentation](https://github.com/hewm2008/RectChr/blob/main/RectChr_manual_English_251006.pdf)</b>

```php
	#  see  more  at pdf
###################################	##Global Parameters #######################################################
SetParaFor = global              	##Sets the current paragraph scope to global, applicable to the entire graphic configuration
File1 = ./InPut.df               	##Main data file path. Required input. Format: [Chr Start End Value1 ...], where NA means this region is not drawn.
#File2 =                         	##Optional second data file path for multi-source data overlay. FileX = ./InPut.fileX
#track_num =                     	##Specifies the number of tracks (layers) in the plot. Default is automatically inferred based on the number of columns in File1 (e.g., Value1 to ValueN)
#chr_spacing_ratio = 0.2         	##Spacing ratio between different chromosomes, calculated based on track height (track_height * chr_spacing_ratio)
#title = "main_Figure"           	##Graphic title and style settings. Supports title_color, title_size, title_shift_x, title_shift_y, etc.
#colormap_conf = col.file        	##Custom color mapping file path, used to define value-to-color mappings (e.g., P1 = "#FE0808")
#chr_orientation = horizontal    	##Chromosome orientation, options: horizontal or vertical

######################################	##Global Chromosome Configuration ####################################################
#chr_zoom_region =               	##Zoom into a specific region, format: chr:start:end (e.g., chr2:1000:5000)
#chr_order =                     	##Specify chromosome order or filter list (if not specified, sorted alphabetically)
#chr_spacing_ratio = 0.2         	##Spacing ratio between chromosomes (based on Sum(track_height))
#chr_label_rotation = 0          	##Rotation angle of chromosome label text

################################	##Canvas and Image Parameters #################################
#canvas_body = 1200              	##Main canvas size,  #canvas_margin_top = 55  #canvas_margin_bottom = 25   #canvas_margin_left = 100   canvas_margin_right = 120

################################# ALL Track Default Parameters (Used If Not Set Individually) #########
SetParaFor = trackALL            	##Sets default parameters for all tracks; subsequent unconfigured trackX will inherit these settings

plot_type = heatmap              	##Supported plot types: heatmap, line, scatter, histogram, LinkS
                                 	##line, scatter/point, histogram, link, LinkS, heatmap(highlights), text, PairWiseLink
                                 	##PairWiseLinkV2, heatmapAnimated/histAnimated, LinkS, shape, ridgeline

#show_columns =                  	##Specifies which columns to display, e.g., File1:4 or File2:4,5
#colormap_brewer_name =          	##Use predefined color palettes (overrides manual colors), e.g., GnYlRd (numeric) or Paired (categorical)
#colormap_reverse = 0            	##Whether to reverse the color gradient (0=normal, 1=reversed)
#colormap_low_color = "#006400"  	##Color for the lowest value   #colormap_mid_color = "#FFFF00"  #colormap_high_color = "#FF0000" 
#background_color = "#B8B8B8"    	##Background color
#upper_outlier_ratio = 0.95      	##Upper outlier threshold, values above this use the max color
#lower_outlier_ratio = 0         	##Lower outlier threshold, values below this use the min color
#Ymax =                          	##Manually set the maximum value for this layer, overriding auto-calculation
#Ymin =                          	##Manually set the minimum value for this layer, overriding auto-calculation
#cap_max_value =                 	##Cap the maximum value    #cap_min_value = 	##Cap the minimum value
#colormap_nlevels = 8            	##Number of color levels in the gradient
#track_height = 20               	##Height of the current track
#track_bg_height_ratio = 1       	##Background height as a proportion of track_height (0-1]
#log_p = 0                       	##Whether to apply log10 transformation to values (0=no, 1=yes)
#padding_ratio = 0               	##Vertical spacing between adjacent tracks within the same chromosome (track_height * padding_ratio)
#colormap_legend_sizeratio =     	##Size of the color legend (width and height)
#yaxis_tick_show = 0             	##Whether to show Y-axis tick labels (0=hide, 1=show)
#colormap_legend_show = 1        	##Whether to show the color gradient legend (0=hide, 1=show)
#colormap_legend_shift_x = 0     	##Horizontal shift of the color legend  #colormap_legend_shift_y = 0  ##Vertical shift of the color legend
#chr_label_shift_x = 0           	##Horizontal shift of chromosome labels   #chr_label_shift_y = 0   ##Vertical shift of chromosome labels
#chr_label_size_ratio = 1.0      	##Font size ratio for chromosome labels (relative to default)
#track_shift_x = 0               	##track shift of x       #track_shift_y = 0         ##track shift of y
###################################	##trackALL. Other Less Common Parameters #######################################################
#text-font-size =                	##Text font size setting
#track_text_size = 1.0           	##Text font size ratio (relative to default)
#...                             	####More parameters

###################################	##trackX Layer Parameters, Inherit All trackALL Parameters #######################################################

#SetParaFor = track2             	##Begin configuring parameters for track 2, numbering starts from 1
#File2 =                         	##Can specify another input file as the data source
#plot_type = hist                	##Plot type: histogram
#show_columns = File2:5          	##Display column 5 from File2 (can be used for scatter plots or other chart types)
#label = "Name"                  	##Label and style settings for this track (label_size label_color label_shift_x label_shift_y label_angle)
#SetParaFor = track3
#plot_type = lines               	##Plot type: line plot
#show_columns = File1:5,6        	##Display columns 5 and 6 from File1

....  #etc

```

</br><b>3.3 Output files</b>
<pre>
out.svg: Output plot in SVG format
out.png: Output plot in png format
</pre>


###  4 . Examples of drawing methods
------------
#### Examples of drawing methods
Here are some examples of basic usage tutorials, and the specific data and configuration can be found in the [Basic_Tutorials](https://github.com/hewm2008/RectChr/tree/main/Basic_Tutorials) of the software  

The following is a simple list of 12 drawing methods,see 
![PlotType.png](https://github.com/hewm2008/RectChr/blob/main/info/PlotType.png)

#### Examples of application scenarios
* Example 1) [Density_heatmap](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example01_Density_heatmap)
![out.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example01_Density_heatmap/OUT1.png)

* Example 2) [T2T Genome](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example02_T2T_telo)
![out.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example02_T2T_telo/OUT1.png)
![out.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example02_T2T_telo/OUT3.png)

* Example 3) [ParentalMaker](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example03_ParentalMaker/)
![out.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example03_ParentalMaker/OUT1.png)

* Example 4) [binMap Fig](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example04_RILBinMap)
Multi - track heatmap, horizontally placed chromosomes
![out.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example04_RILBinMap/OUT1.png)

* Example 5) [Regin Genotype](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example05_RegionHaplotype/)
![out.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example05_RegionHaplotype/OutRegion.png)

* Example 6) [T2T Depth info](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example06_DepthCov)
![out.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example06_DepthCov/OUT1.png)

* Example 7) [Genetics Stat](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example07_Genetics)
![out.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example07_Genetics/OUT1.png)
![out.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example07_Genetics/OUT2.png)
[ZoomRegion](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example09_ZoomRegion)
![out.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example09_ZoomRegion/OUT1.png)

* Example 8)[maker Flag](https://github.com/hewm2008/RectChr/blob/main/Basic_Tutorials/example06_sca2chr_text)

![out.png](https://github.com/hewm2008/RectChr/blob/main/Basic_Tutorials/example06_sca2chr_text/OUT2.png)

* Example 9) [GWAS  Fig](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example08_GWASShape/)
Two layers: the upper layer is a dot plot with increased layer height; the lower layer is for chromosomes, just showing a background bar (other drawing methods are also okay), mainly to illustrate that chromosomes can be placed horizontally.
![out3.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example08_GWASShape/OUT3.png)
![out4.png](https://github.com/hewm2008/RectChr/blob/main/Scene_Usage/example08_GWASShape/OUT4.png)

* Example 10) [QTL region](https://github.com/hewm2008/RectChr/blob/main/Basic_Tutorials/example07_QTL_shape)
  ![QTL.png](https://github.com/hewm2008/RectChr/blob/main/Basic_Tutorials/example07_QTL_shape/OUT2.png)
  ![QTL2.png](https://github.com/hewm2008/RectChr/blob/main/Basic_Tutorials/example08_QTL_ridgeline/OUT1.png)

* Example 11) [LD Map](https://github.com/hewm2008/RectChr/blob/main/Basic_Tutorials/example09_LDMap_PairWiseLink)
![LDmap.png](https://github.com/hewm2008/RectChr/blob/main/Basic_Tutorials/example09_LDMap_PairWiseLink/OUT3.png)

###  5 Advantages

</br>Fast speed and low memory usage
</br>Can customize multiple track of combinations
</br>Can run with Perl, no installation required

###  6 An example image generated by RectChr
------------

There are also many articles published in the paper, which can also prove that there are many examples.
RectChr have been cited in more than <b> 60 times </b> by [searching against google scholar](https://scholar.google.com.hk/scholar?hl=zh-CN&as_sdt=0%2C5&q=RectChr&btnG=)

![RealCite.png](https://github.com/hewm2008/RectChr/blob/main/info/RealCite.png)


###  7 Discussing
------------
- [:email:](https://github.com/hewm2008/RectChr) hewm2008@gmail.com/hewm2008@qq.com
- join the<b><i> QQ Group : 125293663</b></i>

######################swimming in the sky and flying in the sea #############################

