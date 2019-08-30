Shader "Unlit/ImageSequenceAnimation"
{
    Properties
    {
        _Color ("Color Tint",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _HorizontalAmount ("Horizontal Amount",Float) = 4 //该图像在水平方向包含的关键帧图像的个数
        _VerticalAmount ("Vertical Amount",Float) = 4 
        _Speed ("Speed",Range(1,100)) = 30 //控制序列帧动画播放速度
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

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
            
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

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
                //floor用来取整
                float time=floor(_Time.y*_Speed);
                float row=floor(time/_HorizontalAmount);
                float column=time-row*_HorizontalAmount;


                half2 uv=float2(i.uv.x/_HorizontalAmount,i.uv.y/_VerticalAmount);
                uv.x+=column/_HorizontalAmount;
                uv.y-=row/_VerticalAmount;


                // sample the texture
                fixed4 col = tex2D(_MainTex, uv);
                col.rgb*=_Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
