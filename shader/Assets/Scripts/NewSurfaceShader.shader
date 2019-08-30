Shader "Custom/NewSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _ExtrudeAmount("Extrude Amount",float)=0
    }
    SubShader
    {
        //标签告诉你渲染引擎如何以及何时渲染你的着色器。 这里是透明的
        Tags { "RenderType"="Opaque" }
        //多细节层次（LOD)有助于指定在默写硬件上使用哪种着色器，LOD值越大，着色器越复杂且它的值与模型的LOD无关
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        //定义了表面函数surf Standard指定Unity Shader使用标准光照模型 fullforwardshadows指定着色器启用所有常规的阴影类型
        #pragma surface surf Standard fullforwardshadows
        
        //standard surface 默认情况下不暴露编辑vertices属性的函数，我们可以手动添加一个  如果你在改变顶点坐标的时候，阴影没有随之改变，你需要确保添加了”addshadow“
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        //指定编译使用的光照版本 值越大越好 越复杂 越吃系统
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };
        
         //顶点的结构体
         struct a2v
         {
             //[type] [name] :[semantic]
                        
             //获取模型对象的顶点坐标
             float4 vertex:POSITION;
             //获取模型的UV坐标
             float2 uv:TEXCOORD0;
             //模型的法线信息
             float3 normal:NORMAL;
         };

        
        /*struct SurfaceOutput
        {
        fixed3 Albedo;
        fixed3 Normal;
        fixed3 Emission;
        half Specular;
        fixed Gloss;
        fixed Alpha;
        };*/

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _ExtrudeAmount;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        void vert(inout a2v v){
            v.vertex.xyz+=v.normal.xyz*_ExtrudeAmount*sin(_Time.y);
        }
        
        //Unity定义了一个SurfaceOutputStandard 结构体来替代指定像素的颜色值 由于我们正在处理光照和阴影，不单单是直接获取颜色值，需要能够通过SurfaceOutputStandard保存的值来进行计算
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
