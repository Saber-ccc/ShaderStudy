
// 学习 背景图滚动
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/006Animation/ScrollingBackground"
{
    Properties
    {

        _MainTex ("Base Layer", 2D) = "white" {}//较远背景图
        _DetailTex ("2nd Layer", 2D) = "white" {}//较近背景图
        _ScrollX ("Base Layer Scroll Speed", Float) = 1
        _Scroll2X ("2nd Layer Scroll Speed", Float) = 1
        _Multiplier ("Layer Multiplier", Float) = 1
    }
    SubShader
    {
	    Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        Pass
        {
            Tags { "LightMode"="ForwardBase"}

            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
		    #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; //纹理名_ST ST是缩放和平移的缩写  纹理名_ST.xy储存的是缩放值 纹理名_ST.zw储存的事偏移值
            sampler2D _DetailTex;
            float4 _DetailTex_ST; //纹理名_ST ST是缩放和平移的缩写  纹理名_ST.xy储存的是缩放值 纹理名_ST.zw储存的事偏移值
            float _ScrollX;
            float _Scroll2X;
            float _Multiplier;
           
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
                float4 uv : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标  
                o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex) + frac(float2(_ScrollX,0) * _Time.y); //frac 返回标量或每个矢量中各分量的小数部分
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_DetailTex) + frac(float2(_Scroll2X,0) * _Time.y);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed4 firstLayer = tex2D(_MainTex,i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailTex,i.uv.zw);
                fixed4 c = lerp(firstLayer,secondLayer,secondLayer.a);
                c.rgb *= _Multiplier;
                return c;
            }

            ENDCG
        }
    }
    
    FallBack "VertexLit"
}
