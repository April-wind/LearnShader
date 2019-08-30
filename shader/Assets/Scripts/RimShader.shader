// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/RimShader"
{//外发光
    Properties
    {
		//主颜色 || Main Color
		_MainColor("【主颜色】Main Color", Color) = (0.5,0.5,0.5,1)
		//漫反射纹理 || Diffuse Texture
		_DiffuseTex("【漫反射纹理】Texture Diffuse", 2D) = "white" {}
	//边缘发光颜色 || Rim Color
	_RimColor("【边缘发光颜色】Rim Color", Color) = (0.5,0.5,0.5,1)
		//边缘发光强度 ||Rim Power
		_RimPower("【边缘发光强度】Rim Power", Range(0.0, 36)) = 0.1
		//边缘发光强度系数 || Rim Intensity Factor
		_RimIntensity("【边缘发光强度系数】Rim Intensity", Range(0.0, 100)) = 3
    }
    SubShader
    {
		//渲染物体为不透明
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			//设置光照模式
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include"AutoLight.cginc"

			
			//#pragma target 3.0

            struct a2v
            {
                float4 vertex : POSITION;
				float3 normal:NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
				float4 WorldPos:TEXCOORD1;
				float3 normal:NORMAL;
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				//用于内置光照
				LIGHTING_COORDS(3, 4)
            };

			//变量声明
			uniform	float4 _LightColor0;
			uniform float4 _MainColor;
			uniform sampler2D _DiffuseTex;
			//声明DiffuseTex是一张采样图，从而能够进行TRANSFORM_TEX运算
			uniform float4 _DiffuseTex_ST;
			uniform float4 _RimColor;
			uniform float _RimPower;
			uniform float _RimIntensity;

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				//拿顶点的uv去和材质球的tiling和offset作运算， 确保材质球里的缩放和偏移设置是正确的
                o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);//

				o.normal = mul(float4(v.normal, 0), unity_WorldToObject).xyz;
				o.WorldPos = mul(unity_ObjectToWorld, v.vertex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;	
            }

			fixed4 frag(v2f i) : COLOR
            {
				float3 ViewDir = normalize(_WorldSpaceCameraPos.xyz - i.WorldPos.xyz);
				float3 NormalDir = normalize(i.normal);
				float3 LightDir = normalize(_WorldSpaceLightPos0.xyz);

				//计算光照的衰减
				//衰减值
				float Attenuation = LIGHT_ATTENUATION(i);
				//衰减后颜色值
				float AttenColor = Attenuation * _LightColor0.xyz;

				//计算漫反射
				float NdotL = dot(NormalDir,LightDir);
				float3 Diffuse = saturate(NdotL)*AttenColor + UNITY_LIGHTMODEL_AMBIENT.xyz;

				//计算自发光
				//计算边缘强度
				half Rim = 1.0 - max(0, dot(i.normal, ViewDir));

				//计算边缘自发光强度
				float3 Emissive = _RimColor.rgb*pow(Rim, _RimPower)*_RimIntensity;

				//将自发光添加到最终颜色里
				float3 finalColor = Diffuse * (tex2D(_DiffuseTex, i.uv).rgb*_MainColor.rgb)+Emissive;
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
	
	FallBack"Diffuse"
}
