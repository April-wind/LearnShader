Shader "Unlit/BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Brightness("Brightness", Float) = 1
        _Saturation("Saturation", Float) = 1
        _Contrast("Contrast", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always Cull Off ZWrite Off//屏幕后处理shader的标配
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Brightness;
            half _Saturation;
            half _Contrast;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 renderTex = tex2D(_MainTex, i.uv);
                
                //apply brightness 
                fixed3 finalColor = renderTex.rgb * _Brightness;
                
                //apply saturation
                fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g +0.0721 * renderTex.b;//该像素的亮度值
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);//这样的系数可以让饱和度为0
                finalColor = lerp(luminanceColor, finalColor, _Saturation);
                
                //apply contrast 
                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);//这个颜色对比度为0
                finalColor = lerp(avgColor, finalColor, _Contrast);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(finalColor, renderTex.a);
            }
            ENDCG
        }
    }
    Fallback Off
}
