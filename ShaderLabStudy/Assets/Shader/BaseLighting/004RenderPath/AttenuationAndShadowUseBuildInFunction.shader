
// 学习 使用内置方法统一管理光照衰减和阴影 使用Base Pass 和Additional Pass
// 使用逐像素光照 BlinnPhong模型高光 半兰伯特模型漫反射 及 环境光

Shader "ShaderEnter/004RenderPath/AttenuationAndShadowUseBuildInFunction"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0,256)) = 20
    }
    SubShader
    {
    	
		Tags { "RenderType"="Opaque" }
        //对于base pass 他处理的逐像素光源一定是平行光
        Pass
        {
            Tags { "LightModel"="ForwardBase" }

            CGPROGRAM
            
            #pragma multi_compile_fwdbase	 //可以保证使用光照衰减等光照变量可以被正确赋值

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
		    fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
            
            struct a2v
            {
                float4 vertex : POSITION;//模型空间坐标
                float3 normal : NORMAL;//模型顶点法线
            };

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            	
            	SHADOW_COORDS(2) //声明一个用于对阴影纹理采样的坐标 这个宏的参数需要是下一个可用的插值寄存器的索引值 上面是2
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
            	
            	TRANSFER_SHADOW(o); //这个宏用于顶点着色器中计算上一步中声明的阴影纹理坐标
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //环境光 在base pass中计算一次即可，后续addpass无需在计算
				
			 	fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

			 	fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
			 	fixed3 halfDir = normalize(worldLightDir + viewDir);
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

            	//atten内置会声明 这个参数会用于计算光源空间下的坐标对光照衰减纹理采样来得到光照衰减
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);//内置宏 计算光照衰减的阴影

            	
				return fixed4(ambient + (diffuse + specular) * atten , 1.0);
			}
            ENDCG
        }
        
        Pass
        {
            Tags { "LightMode"="ForwardAdd" } //此处多加了一个l 导致光照模型出错
            Blend SrcAlpha One //希望在此pass中，计算的光照结果可以在帧缓存中与之前光照结果叠加
            
            CGPROGRAM
            
			#pragma multi_compile_fwdadd //可以保证使用光照衰减等光照变量可以被正确赋值
            //#pragma multi_compile_fwdadd_fullshadows //可以在additional Pass中开启阴影效果
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
           
            struct a2v
            {
                float4 vertex : POSITION;//模型空间坐标
                float3 normal : NORMAL;//模型顶点法线
            };

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
            	o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                // o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标
                // o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
            	fixed3 worldNormal = normalize(i.worldNormal);
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);//如果是平行光 _WorldSpaceLightPos0则表示光源方向
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);//如果不是 则需要光源位置-点位置，得到指向光源的位置
				#endif
				
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				//这里都需要摄像机 - 顶点位置获得摄像机方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);//BlinnPhong模型
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

            	//判断光衰弱
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif

				return fixed4((diffuse + specular) * atten, 1.0);
            }

            ENDCG
        }
    }
    
    FallBack "VertexLit" //这里调用了VertexLit 中的 pass （LightMode = ShadowCaster）
}
