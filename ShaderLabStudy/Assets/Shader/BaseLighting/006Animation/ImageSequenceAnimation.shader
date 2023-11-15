
// 学习 序列帧动画
// 使用逐像素光照 BlinnPhong模型高光 半兰伯特模型漫反射 及 环境光
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/006Animation/ImageSequenceAnimation"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _HorizontalAmount ("Horizontal Amount", Float) = 4
        _VerticalAmount ("Vertical Amount", Float) = 4
        _Speed ("Speed", Range(1,100)) = 30
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        Pass
        {
            Tags { "LightMode"="ForwardBase"}

            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; //纹理名_ST ST是缩放和平移的缩写  纹理名_ST.xy储存的是缩放值 纹理名_ST.zw储存的事偏移值
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;
           
            struct a2v
            {
                float4 vertex : POSITION;//模型空间坐标
                float3 normal : NORMAL;//模型顶点法线
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
                float3 worldNormal : TEXCOORD0;//也可以用TEXCOORD0
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标  
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                float time = floor(_Time.y * _Speed);//floor 取整
                float row = floor(time/_HorizontalAmount); // 时间/行数 获得对应的行索引
                float column = time - row * _HorizontalAmount;//时间/行数的余数则是列索引
                //
                //对竖直方向的坐标偏移需要使用减法， 这是因为在Unity中纹理坐标竖直方向的顺序（从下到上逐渐增
                //大）和序列帧纹理中的顺序（播放顺序是从上到下）是相反的
                half2 uv = i.uv + half2(column,-row); 
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;

                fixed4 c = tex2D(_MainTex, uv);
                c.rgb *= _Color;
                return c;
            }

            ENDCG
        }
    }
    
    FallBack "Transparent/VertexLit"
}
