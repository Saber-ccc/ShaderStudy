
// 学习 镜子效果 

Shader "ShaderEnter/005HighTexture/Mirror"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}

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
            
		    sampler2D _MainTex;
            
            struct a2v
            {
                float4 vertex : POSITION;//模型空间坐标
				float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
            	float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标
				o.uv = v.texcoord;
            	o.uv.x = 1 - o.uv.x;//翻转 镜子里显示的图像都是左右相反的
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
            	
				return tex2D(_MainTex,i.uv);
			}
            ENDCG
        }

    }
    
    FallBack "Reflective/VertexLit" 
}
