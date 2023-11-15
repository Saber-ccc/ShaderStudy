
// 学习 顶点动画 水流效果
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/006Animation/Water"
{
    Properties
    {

        _MainTex ("Main Tex", 2D) = "white" {}//河流纹理
        _Color ("Color Tint", Color) = (1,1,1,1)
        _Magnitude ("Distortion Magnitude", Float) = 1//水流波动的幅度
        _Frequency ("Distortion Frequency", Float) = 1//波动频率
        _InvWaveLength ("Distortion Inverse Wave Length", Float) = 10//波长的倒数（越大，波长越小）
        _Speed ("Speed", Float) = 0.5//纹理移动速度
    }
    SubShader
    {
	    Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}
        Pass
        {
            Tags { "LightMode"="ForwardBase"}

            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull off //关闭剔除 双面显示
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
		    #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; //纹理名_ST ST是缩放和平移的缩写  纹理名_ST.xy储存的是缩放值 纹理名_ST.zw储存的事偏移值
            float4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
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

                float4 offset;
                offset.yzw = float3(0,0,0);//只对X方向位移，其他为0
                //
                offset.x = sin(_Frequency*_Time.y + v.vertex.x*_InvWaveLength + v.vertex.y*_InvWaveLength + v.vertex.z*_InvWaveLength)*_Magnitude;
                
                o.pos = mul(unity_MatrixMVP,v.vertex + offset);
                
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                o.uv += float2(0,_Time.y * _Speed);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed4 c = tex2D(_MainTex,i.uv);
                c.rgb *= _Color.rgb;
                return c;
            }

            ENDCG
        }
    }
    
    FallBack "Transparent/VertexLit"
}
