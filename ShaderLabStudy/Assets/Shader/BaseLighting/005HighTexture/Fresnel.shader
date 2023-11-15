
// 学习 菲涅尔反射 使用Base Pass 和Additional Pass
// 使用逐像素光照 BlinnPhong模型高光 半兰伯特模型漫反射 及 环境光

Shader "ShaderEnter/005HighTexture/Fresnel"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _FresnelScale ("Fresnel Scale", Range(0,1)) = 0.5
        _Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
    }
    SubShader
    {
    	
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
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
            
		    fixed4 _Color;
			float _FresnelScale;
            samplerCUBE _Cubemap;
            
            struct a2v
            {
                float4 vertex : POSITION;//模型空间坐标
                float3 normal : NORMAL;//模型顶点法线
            };

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
            	float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
  				fixed3 worldViewDir : TEXCOORD2;
				fixed3 worldRefl : TEXCOORD3;
				SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
            	o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
            	
              	o.worldRefl = reflect(-o.worldViewDir, o.worldNormal); //在顶点着色器计算反射 性能比较好
            	
            	TRANSFER_SHADOW(o); //这个宏用于顶点着色器中计算上一步中声明的阴影纹理坐标
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));		
				fixed3 worldViewDir = normalize(i.worldViewDir);		
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //环境光 在base pass中计算一次即可，后续addpass无需在计算

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);//统一计算光照衰弱与阴影

            	//对Cubemap采样 
				fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;
				//菲涅尔反射 F0 + (1 - F0) * (1 - V.N) 5次方
            	fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir,worldNormal),5);
            	
			 	fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));


            	fixed3 color = ambient + lerp(diffuse, reflection, saturate(fresnel)) * atten;
            	
				return fixed4(color, 1.0);
			}
            ENDCG
        }

    }
    
    FallBack "Reflective/VertexLit" 
}
