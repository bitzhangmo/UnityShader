// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Chapter15-Dissolve" {
	Properties {
		// 消融程度
		_BurnAmount ("Burn Amount",Range(0.0,1.0)) = 0.0
		// 烧焦效果的线宽
		_LineWidth ("Burn Line Width",Range(0.0,0.2)) = 0.1
		// 漫反射纹理与法线纹理
		_MainTex ("Base (RGB)",2D) = "white" {}
		_BumpMap ("Normal Map",2D) = "bump" {}
		// 火焰边缘的两种颜色值
		_BurnFirstColor ("Burn First Color",Color) = (1,0,0,1)
		_BurnSecondColor ("Burn Second Color",Color) = (1,0,0,1)
		// 噪声纹理
		_BurnMap ("Burn Map",2D) = "white" {}
	}
	SubShader {
		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			// 关闭面片剔除，当消融时会暴露模型内部构造，只渲染正面会出现错误
			Cull Off

			CGPROGRAM

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			fixed _BurnAmount;
			fixed _LineWidth;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			fixed4 _BurnFirstColor;
			fixed4 _BurnSecondColor;
			sampler2D _BurnMap;
			
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float4 _BurnMap_ST;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f{
				float4 pos : SV_POSITION;
				float2 uvMainTex : TEXCOORD0;
				float2 uvBumpMap : TEXCOORD1;
				float2 uvBurnMap : TEXCOORD2;
				float3 lightDir : TEXCOORD3;
				float3 worldPos : TEXCOORD4;
				SHADOW_COORDS(5)
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				// 计算三张纹理对应的纹理坐标
				o.uvMainTex = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uvBumpMap = TRANSFORM_TEX(v.texcoord,_BumpMap);
				o.uvBurnMap = TRANSFORM_TEX(v.texcoord,_BurnMap);

				TANGENT_SPACE_ROTATION;
				// 将光源方向从模型空间转换到切线空间
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex));
				// 计算世界空间下的顶点位置
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				
				// 阴影纹理的采样坐标
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				// 对噪声纹理进行采样
				fixed3 burn = tex2D(_BurnMap,i.uvBurnMap).rgb;
				// 与消融程度属性相减，当小于零时将该像素剔除
				clip(burn.r - _BurnAmount);

				// 通过剔除的正常进行光照计算
				float3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uvBumpMap));

				// 通过漫反射纹理获得反射率albedo
				fixed3 albedo = tex2D(_MainTex,i.uvMainTex).rgb;
				// 得到漫反射光照
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));
				
				// 计算混合系数t
				fixed t = 1 - smoothstep(0.0,_LineWidth,burn.r - _BurnAmount);
				// 计算烧焦颜色
				fixed3 burnColor = lerp(_BurnFirstColor,_BurnSecondColor,t);
				burnColor = pow(burnColor,5);

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				// 环境光+漫反射+烧焦颜色
				// step用于剔除小于零的像素
				fixed3 finalColor = lerp(ambient + diffuse * atten,burnColor,t*step(0.0001,_BurnAmount));

				return fixed4(finalColor,1);
			}
			ENDCG
		}
		
		pass
		{
			Tags{"LightMode" = "ShadowCaster"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_shadowcaster

			#include "UnityCG.cginc"

			fixed _BurnAmount;
			sampler2D _BurnMap;
			float4 _BurnMap_ST;

			struct v2f
			{
				V2F_SHADOW_CASTER;

				float2 uvBurnMap : TEXCOORD1;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
				o.uvBurnMap = TRANSFORM_TEX(v.texcoord,_BurnMap);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 burn = tex2D(_BurnMap,i.uvBurnMap).rgb;
				clip(burn.r - _BurnAmount);

				SHADOW_CASTER_FRAGMENT(i);
			}

			ENDCG
		}

	}
	FallBack "Diffuse"
}
