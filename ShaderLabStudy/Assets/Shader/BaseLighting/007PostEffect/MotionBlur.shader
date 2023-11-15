
// 学习 图像后处理 运动模糊
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/007PostEffect/MotionBlur"
{
Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurAmount ("Blur Amount", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		fixed _BlurAmount;
		
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};
		
		v2f vert(appdata_img v) {
			v2f o;
			
			o.pos = UnityObjectToClipPos(v.vertex);
			
			o.uv = v.texcoord;
					 
			return o;
		}
		
		fixed4 fragRGB (v2f i) : SV_Target {
			return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
		}
		
		half4 fragA (v2f i) : SV_Target {
			return tex2D(_MainTex, i.uv);
		}
		
		ENDCG
		
		ZTest Always Cull Off ZWrite Off
		//之所以要分开通道 ，是因为在更新RGB时我们需要设置它的A通道来混合图像，但又不希望A通道的值写入渲染纹理中
		
		Pass {
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB //更新RGB通道
			
			CGPROGRAM
			
			#pragma vertex vert  
			#pragma fragment fragRGB  
			
			ENDCG
		}
		
		Pass {   
			Blend One Zero
			ColorMask A //更新A通道
			   	
			CGPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment fragA
			  
			ENDCG
		}
	}
 	FallBack Off
}
