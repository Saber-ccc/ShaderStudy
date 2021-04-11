Shader "CC/ShowTexture/ShowBlendTexture"
{
	//展示基础纹理，并做了透明度混合
	//blend 就是对透明的物体进行混合的，处于光栅化的最后阶段
	//实现透明效果有两种方式：
	//(1)透明度测试(Alpha Test):透明度小于某一个值，对应的片元就被舍弃,得到的效果要么完全透明， 要么完全不透明
	//(2)透明度混合(Alpha Blending):使用片元的透明度作为混合因子，与在颜色缓冲区内的颜色进行混合，得到新的颜色。

    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
		//使用透明度测试（Alpha Test）时需要用AlphaTest
		//使用透明度混合（Alpha Blending）时需要用Transparent
        Tags { "Queue"="Transparent" }//此处渲染队列一定要改，不然黑屏效果遮挡其他物体

        Pass
        {
            //透明度混合Transparent_Blend 目前处理的像素如何与它后面像素混合

            Blend SrcAlpha OneMinusSrcAlpha
			//它的意思是将源颜色乘上源颜色的透明度，与目标颜色(当前渲染在屏幕上的其他颜色)乘（1 - 原颜色的透明度）的结果相加，公式如下：
			//OutColor = SrcColor * ScrAlpha + DstColor * (1 - SrcAlpha)

			//使用透明度测试不需要关闭深度写入
			//使用透明度混合时需要关闭深度写入
			Zwrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;//储存_MainTex中的Tiling 与 Offset 值 
            //x contains X tiling value
            //y contains Y tiling value
            //z contains X offset value
            //w contains Y offset value

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);//主要作用是拿顶点的uv去和材质球的tiling和offset作运算， 确保材质球里的缩放和偏移设置是正确的。
                //等价于o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);//tex2D这个方法来获取纹理中的颜色，并直接使用颜色进行着色。
                return col;
            }
            ENDCG
        }
    }
}
