
// 学习 噪声-水波效果
//噪声纹理通常会作为一个高度图，以不断修改水面的法线方向
//使用和时间相关的变量来对噪声纹理进行采样，当得到法线信息后，在进行正常的反射+折射计算，得到最后的水面波动效果

Shader "ShaderEnter/009Noise/WaterWave" {
	Properties {
		_Color ("Main Color", Color) = (0, 0.15, 0.115, 1)//水面颜色
		_MainTex ("Base (RGB)", 2D) = "white" {}//水面波纹材质纹理
		_WaveMap ("Wave Map", 2D) = "bump" {}//由噪声纹理生成的法线纹理
		_Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}//模拟反射的立方体纹理
		_WaveXSpeed ("Wave Horizontal Speed", Range(-0.1, 0.1)) = 0.01//控制水平是平移速度
		_WaveYSpeed ("Wave Vertical Speed", Range(-0.1, 0.1)) = 0.01
		_Distortion ("Distortion", Range(0, 100)) = 10//控制模拟折射时图像的扭曲程度
	}
	SubShader {
		// We must be transparent, so other objects are drawn before this one.
		//确保渲染该物体时，所有不透明物体都已经渲染到屏幕上了，否则无法得到“透过水面看到的图像”
		Tags { "Queue"="Transparent" "RenderType"="Opaque" }
		
		// This pass grabs the screen behind the object into a texture.
		// We can access the result in the next pass as _RefractionTex
		GrabPass { "_RefractionTex" }
		
		Pass {
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			#pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _WaveMap;
			float4 _WaveMap_ST;
			samplerCUBE _Cubemap;
			fixed _WaveXSpeed;
			fixed _WaveYSpeed;
			float _Distortion;	
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT; 
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;  
				float4 TtoW1 : TEXCOORD3;  
				float4 TtoW2 : TEXCOORD4; 
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.scrPos = ComputeGrabScreenPos(o.pos);//得到对应被抓取屏幕图像的采样坐标
				
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _WaveMap);
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
				
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);
				
				// 得到speed偏移值、对法线纹理进行两次采样（这是为了模拟两层交叉的水面波动的效果）
				fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
				fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
				//两次结果相加并归一化后得到切线空间下的法线方向
				fixed3 bump = normalize(bump1 + bump2);
				
				// Compute the offset in tangent space
				//_Distortion和_RefractionTex_TexelSize来对屏幕图像的采样坐标进行偏移 模拟折射效果。 
				//，在计算偏移后的屏幕坐标时 ，我们把偏移址和屏幕坐标的Z分量相乘，这是为了模拟深度越大、折射程度越大的效果
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				fixed3 refrCol = tex2D( _RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;
				
				// Convert the normal to world space
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				fixed4 texColor = tex2D(_MainTex, i.uv.xy + speed);
				fixed3 reflDir = reflect(-viewDir, bump);
				fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb * _Color.rgb;
				
				fixed fresnel = pow(1 - saturate(dot(viewDir, bump)), 4);
				fixed3 finalColor = reflCol * fresnel + refrCol * (1 - fresnel);
				
				return fixed4(finalColor, 1);
			}
			
			ENDCG
		}
	}
	// Do not cast shadow
	FallBack Off
}