
// 学习 图像后处理 调整屏幕亮度、饱和度、对比度
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/007PostEffect/BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}//河流纹理
        _Brightness ("Brightness", Float) = 1 //屏幕亮度
        _Saturation ("Saturation", Float) = 1//饱和度
        _Contrast ("Contrast", Float) = 1//对比度
    }
    SubShader
    {
	    Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}
        Pass
        {
            Tags { "LightMode"="ForwardBase"}

            ZTest Always
            ZWrite off //深度写入关闭 防止挡住后面被渲染的物体
            Cull off //关闭剔除 双面显示
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
		    #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; //纹理名_ST ST是缩放和平移的缩写  纹理名_ST.xy储存的是缩放值 纹理名_ST.zw储存的事偏移值
            half _Brightness;
            half _Saturation;
            half _Contrast;
            
            struct a2v
            {
                float4 vertex : POSITION;//模型空间坐标
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = mul(unity_MatrixMVP,v.vertex);
                
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed4 renderTex = tex2D(_MainTex,i.uv);

                //应用亮度
                fixed3 finalColor = renderTex.rgb * _Brightness; //原颜色 * 亮度系数

                //应用饱和度 
                fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                fixed3 luminanceColor = fixed3(luminance,luminance,luminance);
                finalColor = lerp(luminanceColor,finalColor,_Saturation);

                //应用对比度
                fixed3 avgColor = fixed3(0.5,0.5,0.5);
                finalColor = lerp(avgColor,finalColor,_Contrast);
                
                return fixed4(finalColor,renderTex.a);
            }

            ENDCG
        }
    }
    
    FallBack Off
}
