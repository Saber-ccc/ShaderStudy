Shader "CC/LittleWhiteWay/Vertex_DiffuseReflash"
{
    //逐顶点漫反射
    Properties
    {
        _Diffuse("光源颜色", Color) =(1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Pass
        {
			//定义光照模式，只有正确定光照模式，才能得到一些Unity内置光照变量
            Tags{"LightMode" = "ForwardBase"}
                
           

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

			//定义全局变量
			fixed4 _Diffuse;

            struct a2v
            {
                float4 vertex : POSITION;//获取物体坐标
                float2 normal : NORMAL;//获取法向量
            };

            struct v2f
            {
				fixed3 color : COLOR;
                float4 sv_Pos : SV_POSITION;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.sv_Pos = UnityObjectToClipPos(v.vertex);//从物体坐标转为裁剪坐标
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//通过模型到世界的转置逆矩阵计算得到世界空间内的顶点法向方向（v.normal存储的是模型空间内的顶点法线方向）
				fixed3 worldNormal = normalize(mul( v.normal , (float3x3)unity_WorldToObject) );
				//得到世界空间内的光线方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//根据Lambert定律计算漫反射 saturate函数将所得矢量或标量的值限定在[0,1]之间
				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal, worldLight));

				o.color = diffuse + ambient;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				return fixed4(i.color,1.0);
            }
            ENDCG
        }
    }
}
