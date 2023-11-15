// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// 学习 逐像素光照 半兰伯特模型漫反射 及 环境光  更加平滑的光照效果 当前用的是兰伯特光照模型
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多
// 无法解决背光面明暗一样的缺点  为此一种改善技术被提出来了，半兰伯特光照模型

Shader "ShaderEnter/001Light_HalfLambert/Light_HalfLambert_Fragment_Diffuse"
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
                float3 worldNormal : TEXCOORD0;//也可以用TEXCOORD0
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);//模型空间法线转为世界空间法线
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//获取环境光颜色
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);//获取世界空间光源方向 假设场景只有一个光源且是平行光

                //此处通过放大0.5倍+0.5的偏移 实现把点积范围从【-1,1】变为【0,1】 半兰伯特 有效改善背面明暗一样的问题
                fixed halfLambert = dot(worldNormal,worldLight)*0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;//计算漫反射
                fixed3 color = ambient + diffuse;
                return fixed4(color,1.0);
            }

            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
