// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Chapter7-RampTexture" {
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_RampTex("Ramp Tex",2D) = "White" {}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldPos = mul(unity_ObjectToWorld,i.vertex).xyz;
				// to calculate the texture pos after moving
				o.uv = TRANSFORM_TEX(i.texcoord,_RampTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed halfLambert = 0.5 * dot(worldLightDir,worldNormal) + 0.5;
				fixed3 diffuseColor = tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb * _Color.rgb;

				fixed3 diffuse = _LightColor0.rgb * diffuseColor;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(worldNormal,halfDir),0),_Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Specular"
}
