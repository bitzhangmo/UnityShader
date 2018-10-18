// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// 对于细分程度较低的模型，逐顶点光照容易出现一些视觉问题。
Shader "Custom/Chapter6-DiffuseVertexLevel" {
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;
				// 将顶点位置从模型空间转换到裁剪空间中
				o.pos = UnityObjectToClipPos(v.vertex);
				// 通过内置变量获得环境光部分
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				// 将法线与光源方向转换到统一坐标系下进行点积
				// 计算法线的转换需要使用逆转置矩阵
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
			
				o.color = ambient + diffuse;

				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.color,1.0);
			}
			
			ENDCG
		}
	}
	
	Fallback "Diffuse"
}
