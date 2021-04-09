Shader "CC/Toon/FirstToon"
{
	//卡通效果中的漫反射光效果 根据模型法线与世界坐标光源进行点积，并光线强度变成1或0
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("颜色",color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
				float3 normal : NORMAL;//NORMAL 为Unity内定的语义，把三维物体的法线向量与normal变量联系起来
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
            };

			//全局变量
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Color;//会与上述属性中自动绑定 (需要名字一致)

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.normal = v.normal;
				
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv)* _Color;//包含贴图的颜色
				//fixed4 col = _Color;//不包含贴图效果

				//漫反射光逻辑 用点积来表示
				//_WorldSpaceLightPos0 ：U3D内定的参数 世界坐标系的光源坐标 一般用_开头 
				//（定义哪些变量需要查阅官方文档）https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
				float intensity = dot(_WorldSpaceLightPos0, i.normal);

				//卡通效果：平滑过渡的阴影转换成亮暗两个色块即可
				//（If语句在shader中的执行效率不高，应该尽量避免）
				//smoothstep为shader内置函数 表示小于最小数0为0，大于最大数0.01为1 
				intensity = smoothstep(0, 0.05, intensity);

				col *= intensity;
                return col;
            }
            ENDCG
        }
    }
}
