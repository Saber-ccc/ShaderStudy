
// 学习 广告牌 始终朝向摄像机
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/006Animation/Water"
{
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1 //调整是固定法线还是固定指向上的方向 即约束垂直方向的程度
	}
	SubShader {
		// Need to disable batching because of the vertex animation
		//包含模型空间顶点动画的shader需要把合批关掉，批处理会合并所有相关的模型 这些模型各自的模型空间就会被丢失
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}
		
		Pass { 
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _VerticalBillboarding;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert (a2v v) {
				v2f o;
				
				// 模型空间原点 作为广告牌锚点
				float3 center = float3(0, 0, 0);
				float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos, 1));
				
				float3 normalDir = viewer - center;
				//_VerticalBillboarding=1 意味着法线方向固定为视角方向  _VerticalBillboarding= 0意味着向上方向固定为(0 ,1, 0)
				normalDir.y =normalDir.y * _VerticalBillboarding;
				normalDir = normalize(normalDir);
				//我们得到了粗略的向上方向
				// 为了防止法线方向和向上方向平行（如果平行，那么叉
//积得到的结果将是错误的） 我们对法线方向的y分量进行判断，以得到合适的向上方向。然后，
//据法线方 向和粗略的向上方向得到向右方向
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));
				//我们又根据准确的法线方向和向右方向得到最后的向上方向
				upDir = normalize(cross(normalDir, rightDir));
				
				// 我们根据原始的位置相对千铀点的偏移址以及3个正交基矢量，以计算得到新的顶点位置
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
              
				o.pos = UnityObjectToClipPos(float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 c = tex2D (_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				
				return c;
			}
			
			ENDCG
		}
	} 
	FallBack "Transparent/VertexLit"
}
