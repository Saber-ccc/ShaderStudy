// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// 学习 逐顶点光照 兰伯特模型漫反射 及 环境光
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/001Light_Lambert/Light_Lambert_Vertex_Diffuse"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightModel"="ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;
           
            struct a2v
            {
                float4 vertex : POSITION;//模型空间坐标
                float3 normal : NORMAL;//模型顶点法线
            };

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
                float3 color : COLOR;//也可以用TEXCOORD0
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//获取环境光颜色
                fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));//模型空间法线转为世界空间法线
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);//获取世界空间光源方向 假设场景只有一个光源且是平行光
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));//计算漫反射
                //saturate 是CG提供的一种函数 作用是把参数截取到【0,1】的范围内

                o.color = ambient + diffuse;
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                return fixed4(i.color,1.0);
            }

            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
