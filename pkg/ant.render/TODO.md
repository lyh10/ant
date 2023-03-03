#### 架构
1. RT需要使用FrameGraph的形式进行修改。目前postprocess尤其需要这个修改进行不同pass的引用；
2. 使用DeferredShading。目前的one pass deferred能够很好解决deferrd shading占用过多带宽的问题；

#### Bug
##### 已经完成
1. 修复引擎在D3D12/Vulkan中的问题；
2. 修复bloom后处理，在emissive color值很高的时候，依然没有bloom的效果。具体使用furnace-1.glb这个文件用于测试；(2022.11.08已经完成)
3. 将render_layer也bgfx.submit中的depth关联起来，并将viewmode改成与depth相关的设定；(2023.02.06已经完成)

##### 未完成
1. 修复shader下的cubemap resource，绑定为texture2d array的问题。具体重现的方法是，在iOS开发环境下，打开对应的shader validation等相关的debug选项就会有相应的报错；

#### 编辑器相关
1. 优化材质编辑器

#### 优化
##### 已经完成
1. 顶点相关：
  - 顶点压缩。
    1) 使用四元数多normal/tangent/bitangent进行压缩；(2022.11.08已经完成)
    2) 使用更多的16bit的顶点数据，以更大程度上压缩顶点占用的数量；
2. 后处理
  1) Bloom目前的效果并不好；(2022.11.08已经完成)
3. 使用FXAA/TAA，解决bgfx在MSAA下，不同平台直接很多bug的问题。(2022.11.08已经完成)
4. 使用compute shader将MSAA的深度resolve到普通的深度；(2022.11.08已经完成。但不同的机器resolve msaa的depth硬件不一定支持)
5. 增强阴影的效果，包括精度和和filter的阴影，或对比使用PCF的效果；(2022.11.08已经完成)
6. 着色器优化。尽可能使用mediump和lowp格式。目前默认全部都是highp格式；（2022.12.31已经完成）
7. 转换到Vulkan（全平台支持，Mac和iOS使用MoltenVK）。（2023.1.10已经完成）
8. 清理引擎中的varying.def.sc文件。引擎内，应该只使用一个varying的文件定义，不应该过度的随意添加。后续需要针对VS_Output与FS_Input进行关联；
9. 调整iOS和Android下的ASTC压缩格式。目前强制使用了ASTC4x4，因为之前bgfx不支持ASTC6x6，最近更新了，看看是否ASTC的格式都支持全了；
##### 未完成
1. 顶点相关：
  - 顶点数据使用不同的流。目前所有顶点都打包到一个流里面，当某个着色器不会访问到对应的顶点数据的时候，相应的带宽就会被浪费掉了。但目前代码很多地方都依赖着只有一个流的逻辑，多个流的情况是否真的能够提交性能还需要验证；
2. 优化PBR中的GGX的计算。具体看：http://filmicworlds.com/blog/optimizing-ggx-shaders-with-dotlh/；
3. 关于ibl:
  1) 离线计算ibl相关的数据，将目前的compute shader中计算的内容转移到cpu端，并离线计算；
  2) 使用sh(Spherical Harmonic)来表示irradiance中的数据；
4. 优化polyline的效果。启用FXAA之后，polyline的线会丢失；
5. 针对Vulkan上的subpass对渲染的render进行相应的优化；
6. 后处理优化
  1) 后处理的DoF是时候要解决了。bgfx里面有一个one pass的DoF例子，非常值得参考；
  2) Color Grading需要用于调整颜色；
  3) tonemapping能够预先bake到一张贴图里面，而不需要单独在fragment阶段进行计算。具体要看filament里面的tonemapping的操作；
  4）AO效果和效率的优化。效果：修复bent_normal和cone tracing的bug；效率：使用hi-z提高深度图的采样（主要是采样更低的mipmap，提高缓存效率）；
7. 优化动画计算，将skinning的代码从vertex shader放到compute shader中，并消除shadow/pre-depth/main pass中分别重复的计算（https://wickedengine.net/2017/09/09/skinning-in-compute-shader/）；
8. 水渲染；
9. 点光源，包括point、spot和rectangle/plane的区域光，包括其对应的阴影；
10. 使用Hi-Z的方式进行剔除；
11. 对相同材质的物体进行排序渲染，目前渲染顺序的提交，都是按照提交的先后次序来的。还需要单独对alpha test的物体进行分类（分类的队列顺序应该为：opaque->alpha test-> translucent）。而对于translucent的物体来讲，还需要根据从远到近的排序来渲染（避免alpha blend错误）；
12. 考虑一下把所有的光照计算都放在view space下面进行计算。带来的好处是，u_eyePos/v_distanceVS/v_posWS这些数据都不需要占用varying，都能够通过gl_FragCoord反算回来（某些算法一定需要做这种计算）；
13. 渲染遍历在场景没有任何变化的时候，直接用上一帧的数据进行提交，而不是现在每一帧都在遍历；
14. 优化bgfx的draw viewid和compute shader viewid；
15. 解决动态材质的问题；
  1). 需要把vs_pbr.sc里面的VS_Input和VS_Ouput拆分出来。目前已经定义好了，还需要后续的跟进；

#### 新功能/探索
##### 已经完成
1. 阴影的VSM；  //2022.09.29已经完成，使用的是ESM。

##### 未完成
1. 天气系统。让目前游戏能够昼夜变化。一个简单的方式是使用后处理的color grading改变色调，另外一个更正确的方法是使用与烘培的大气散射模拟天空，将indirect lighting和天空和合拼；（2023.02.22已经暂停，对于移动设备并不友好）；
2. FSR。详细看bgfx里面的fsr例子；
2. SDF Shadow；
3. Visibility Buffer；
4. GI相关。SSGI、SSR、SDFGI(https://zhuanlan.zhihu.com/p/404520592)、DDGI(Dynamic Diffuse Global Illumination，https://morgan3d.github.io/articles/2019-04-01-ddgi/)等；
5. LOD；
6. 延迟渲染。延迟渲染能够降低为大量动态光源的计算。但移动设备需要one pass deferred的支持。Vulkan在API层面上支持subpass的操作，能够很好地实现这个功能。唯一需要注意的是，使用了MoltenVK的iOS是否能够支持这个功能；

#### 增强调试功能
1. 修复bgfx编译后的vulkan着色器无法在renderdoc进行单步调试；
2. 影子。只管的在屏幕上看到对应的shadowmap、csm frustum等；
3. 添加一个overdraw的模式，观察哪些像素是背多次渲染了。详细参考unity和虚幻上的做法；
4. bgfx支持查看每一个view下cpu/gpu时间，但在init的时候加上profile=true，还是无法取出每个view的时间；