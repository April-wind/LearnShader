// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/AlphaBlendMat"
{
    Properties
    {
        _Color("Color Tint",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale("AlphaScale",Range(0,1))=1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100

    
        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            Cull Front//先剔除正面 以保证背面先被渲染
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal :TEXCOORD1;
                float3 worldPos :TEXCOORD2;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed3 albedo=col.rgb*_Color.rgb;

                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

                fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(ambient+diffuse,col.a*_AlphaScale);
            }
            ENDCG
        }
        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            Cull Back
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal :TEXCOORD1;
                float3 worldPos :TEXCOORD2;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed3 albedo=col.rgb*_Color.rgb;

                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

                fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(ambient+diffuse,col.a*_AlphaScale);
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
