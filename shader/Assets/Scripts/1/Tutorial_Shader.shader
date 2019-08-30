//指定着色器代码存放在什么位置。双引号的字符串告诉unity在哪里查找Shader
Shader "Unlit/Tutorial_Shader"{
    //属性块中可以传递一些自定义数据,在这里声明的数据会出现在unity editor面板上 溶解效果
    Properties{
        //name ("display name",type)=default value
        _Color("Totally Rad Color",Color)=(1,1,1,1)
        _MainTexture("Main Texture",2D)="white"{}
        _DissolveTexture("Dissolve Texture",2D)="white"{}
        //Range(0,1)代表一个(0,1)的浮点值 
        _DissolveCutoff("Dissolve Cutoff",Range(0,1))=1
        _ExtrudeAmount("Extrude Amount",float)=0
    }
    //每一个shader有一个或者多个subshaders,如果你的应用将被部署到多种平台（移动、PC、主机）,添加多个Subshader是非常有用的。例如：你可能想要写为PC/Desktop写一个高质量的Subshader,为移动端写一个低质量,但速度更快的Subshader.
    SubShader{
        //每个SubShader至少有一个pass，他是对象渲染的位置
        Pass{
            //我们实际写的所有shader代码都在CG 和ENDCG之间
            CGPROGRAM
                //告诉unity 顶点函数和片元函数是什么
                #pragma vertex vertexFunction
                #pragma fragment fragmentFunction
                
                //我们可以使用这个文件中包含的一些助手函数
                #include "UnityCG.cginc"
                
                //顶点的结构体
                struct a2v{
                    //[type] [name] :[semantic]
                    
                    //获取模型对象的顶点坐标
                    float4 vertex:POSITION;
                    //获取模型的UV坐标
                    float2 uv:TEXCOORD0;
                    //模型的法线信息
                    float3 normal:NORMAL;
                };
                
                //片元的结构体
                struct v2f{
                    //最终渲染的顶点的位置
                    float4 position:SV_POSITION;
                    
                    float2 uv:TEXCOORD0;
                };
                
                //从CG中获取属性
                float4 _Color;
                sampler2D _MainTexture;
                sampler2D _DissolveTexture;
                float _DissolveCutoff;
                float _ExtrudeAmount;
                
                v2f vertexFunction(a2v v){
                    v2f o;
                    
                    v.vertex.xyz+=v.normal.xyz*_ExtrudeAmount*sin(_Time.y);//_Time被包含在UnityCG.cginc中 y代表秒
                    
                    //获取顶点的正确位置,使用Unity中提供的UnityObjectToClipPos()函数（这个函数的作用是将世界空间的模型坐标转换到裁剪空间，函数内部封装了实现顶点坐标变换的具体细节，如矩阵变换等等）
                    o.position=UnityObjectToClipPos(v.vertex);
                    
                    //从模型传递UV纹理到片元函数
                    o.uv=v.uv;
                    
                    return o;
                }
                //片元函数将返回一个RGBA,输出语义是SV_TARGET
                fixed4 fragmentFunction(v2f i):SV_TARGET{
                    //return _Color;
                    float4 textureColor=tex2D(_MainTexture,i.uv);
                    float4 dissolveColor=tex2D(_DissolveTexture,i.uv);
                    
                    _DissolveCutoff+=sin(_Time.y);
                    //clip函数检查参数是否小于0 若小于0 则丢弃该像素 不去绘制
                    clip(dissolveColor.rgb-_DissolveCutoff);
                    //return textureColor;
                    return textureColor*_Color;
                }
            ENDCG
        }
    }
}