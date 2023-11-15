
// 学习 图像后处理 运动模糊 基于深度图的实现
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/007PostEffect/MotionBlur"
{
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float4x4 _CurrentViewProjectionInverseMatrix;//C#传进来  当前帧的视角*投影矩阵的逆矩阵
		float4x4 _PreviousViewProjectionMatrix; //C#传进来 上一帧摄像机的视角*投影矩阵
		half _BlurSize;
		
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
		};
		
		v2f vert(appdata_img v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;

			//在DX平台上需要处理平台差异导致的图像反转问题
			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv_depth.y = 1 - o.uv_depth.y;
			#endif
					 
			return o;
		}
		
		fixed4 frag(v2f i) : SV_Target {
			// 获取此像素处的深度缓冲区值。 
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
			// H是该像素处的视口位置，范围为-1到1。
			float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
			// Transform by the view-projection inverse.
			float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
			// 除以w得到世界位置。
			float4 worldPos = D / D.w;
			
			// 当前视口位置
			float4 currentPos = H;
			// Use the world position, and transform by the previous view-projection matrix.
			//使用前一帧 视角*投影矩阵 得到前一帧在NDC(屏幕空间)下的坐标
			float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
			// Convert to nonhomogeneous points [-1,1] by dividing by w.
			previousPos /= previousPos.w;
			
			// 计算前一帧与当前帧在屏幕空间下的位置差 得到该像素的速度
			float2 velocity = (currentPos.xy - previousPos.xy)/2.0f;

			//使用该速度值对它的邻域像素进行采样，相加后取平均值得到一个模糊的效果
			float2 uv = i.uv;
			float4 c = tex2D(_MainTex, uv);
			uv += velocity * _BlurSize;
			for (int it = 1; it < 3; it++, uv += velocity * _BlurSize) {
				float4 currentColor = tex2D(_MainTex, uv);
				c += currentColor;
			}
			c /= 3;
			
			return fixed4(c.rgb, 1.0);
		}
		
		ENDCG
		
		Pass {      
			ZTest Always Cull Off ZWrite Off
			    	
			CGPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment frag  
			  
			ENDCG  
		}
	} 
	FallBack Off
}
