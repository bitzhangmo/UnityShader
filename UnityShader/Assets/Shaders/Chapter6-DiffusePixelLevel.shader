Shader "Custom/Chapter6-DiffusePixelLevel" {
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}
	SubShader
	{
		Pass
		{
			// 内置光照变量
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
				fixed3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				// 将顶点位置从模型空间转换到裁剪空间中
				o.pos = UnityObjectToClipPos(v.vertex);
				// 将法线与光源方向转换到统一坐标系下进行点积
				// 计算法线的转换需要使用逆转置矩阵
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				// 环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				// 世界坐标下的归一化法向量
				fixed3 worldNormal = normalize(i.worldNormal);
				// 世界坐标下的归一化光照方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				// 计算漫反射光照：入射光的颜色 * 漫反射系数 * Cos(n,l);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
				// 环境光下的颜色：环境光颜色 + 漫反射光照颜色
				fixed3 color = ambient + diffuse;

				// 返回四元数Color
				return fixed4(color,1.0);
			}
			
			ENDCG
		}
	}
	
	Fallback "Diffuse"
}
