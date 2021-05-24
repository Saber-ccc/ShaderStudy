Shader "CC/ReplaceShader//ShowTwoTexture"
{
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			//定义全局变量
			sampler2D _OpaqueTex;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//因为SetReplacementShader 会造成上下左右颠倒，因此这里需要做个反转
				o.uv = fixed2(1 - v.uv.x, 1 - v.uv.y);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_OpaqueTex,i.uv);
				return col;
			}
			ENDCG
		}
	}

		SubShader
			{
				tags { "rendertype" = "transparent" }

				Pass
				{

					ZWrite Off //关闭深度写入
					Blend SrcAlpha OneMinusSrcAlpha //开启混合模式

					CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag

					#include "UnityCG.cginc"

					struct appdata
					{
						float4 vertex : POSITION;
						float2 uv:TEXCOORD0;
					};

					struct v2f
					{
						float4 vertex : SV_POSITION;
						float2 uv:TEXCOORD0;
					};

					//定义全局变量
					sampler2D _TransparentTex;

					v2f vert(appdata v)
					{
						v2f o;
						o.vertex = UnityObjectToClipPos(v.vertex);
						//因为SetReplacementShader 会造成上下左右颠倒，因此这里需要做个反转
						o.uv = fixed2(1 - v.uv.x, 1 - v.uv.y);
						return o;
					}

					fixed4 frag(v2f i) : SV_Target
					{
						fixed4 col = tex2D(_TransparentTex,i.uv);
						return col;
					}
					ENDCG
				}
			}
}
