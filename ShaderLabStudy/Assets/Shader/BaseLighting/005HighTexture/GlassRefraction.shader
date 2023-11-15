
// 学习 玻璃效果 使用Base Pass 
// 使用逐像素光照 BlinnPhong模型高光 半兰伯特模型漫反射 及 环境光

Shader "ShaderEnter/005HighTexture/GlassRefraction"
{
    Properties
    {
		_MainTex ("Main Tex", 2D) = "white" {} //玻璃材质
		_BumpMap ("Normal Map", 2D) = "bump" {} //玻璃法线纹理
		_Cubemap ("Environment Cubemap", Cube) = "_Skybox" {} //模拟反射的环境纹理
		_Distortion ("Distortion", Range(0, 100)) = 10 //控制模拟折射时图像的扭曲程度
		_RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0//控制折射程度 为0时只包含反射效果 为1时只包含折射效果
        
    }
    SubShader
    {
    	//设为Queue为Transparent确保该物体渲染时，所有不透明物体都已经被渲染到屏幕上，否则无法正确得到“透过玻璃看到的图像”
		Tags { "RenderType"="Opaque" "Queue"="Transparent"} 
    	
 		GrabPass { "_RefractionTex" }//表示定义一个抓取屏幕图像的Pass 直接声明纹理名称“_RefractionTex”性能更好
    	//如果不指定名字，那么场景中有多个物体都使用了这样的形式来转屏幕时，Unity都会为它单独进行一次昂贵的屏幕抓取操作
    	//而指定名字后，每一帧只会执行一次抓取操作，后续其他物体都会使用同一张抓取的图像
        Pass
        {
	        CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;//表示抓取屏幕的纹理的纹素大小
            
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT; 
				float2 texcoord: TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;  
			    float4 TtoW1 : TEXCOORD3;  
			    float4 TtoW2 : TEXCOORD4; 
			};

			v2f vert (a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.scrPos = ComputeGrabScreenPos(o.pos);//得到对应被抓取的屏幕图像的采样坐标
				
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  //切线
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; //副切线
				
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {		
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				// Get the normal in tangent space
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));	
				
				// Compute the offset in tangent space
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;
				
				// Convert the normal to world space
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				fixed3 reflDir = reflect(-worldViewDir, bump);
				fixed4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;
				
				fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
				
				return fixed4(finalColor, 1);
			}
			
            ENDCG
        }

    }
    
    FallBack "Reflective/VertexLit" 
}
