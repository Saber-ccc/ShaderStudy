
// 学习 图像后处理 边缘检测
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/007PostEffect/EdgeDetection"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}//河流纹理
        _EdgeOnly ("_EdgeOnly", Float) = 1 //屏幕亮度
        _EdgeColor ("_EdgeColor", Color) = (0,0,0,1)//饱和度
        _BackgroundColor ("_BackgroundColor", Color) = (1,1,1,1)//对比度
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
            #pragma fragment fragSobel
		    #include "UnityCG.cginc"

            sampler2D _MainTex;
            uniform half4 _MainTex_TexelSize; //纹理名_TexelSize unity提供了访问对应的每个纹素的大小， 一张512X512 该值为1/512
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
                float2 uv[9] : TEXCOORD0;
            };

            v2f vert(appdata_img v)
            {
                v2f o;

                o.pos = mul(unity_MatrixMVP,v.vertex);
                
                half2 uv = v.texcoord;
                //Sobel算子采样
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1,-1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0,-1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1,-1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0,0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1,0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1,1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0,1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1,1);
                return o;
            }

			fixed luminance(fixed4 color) {
				return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
			}

            //计算当前像素的梯度值Edge
			half Sobel(v2f i) {
				const half Gx[9] = {	-1,  0,  1,
										-2,  0,  2,
										-1,  0,  1};
				const half Gy[9] = {	-1, -2, -1,
										0,  0,  0,
										1,  2,  1};		
				
				half texColor;
				half edgeX = 0;
				half edgeY = 0;
				for (int it = 0; it < 9; it++) {
					texColor = luminance(tex2D(_MainTex, i.uv[it]));
					edgeX += texColor * Gx[it];
					edgeY += texColor * Gy[it];
				}
				
				half edge = 1 - abs(edgeX) - abs(edgeY);
				
				return edge;
			}
			
			fixed4 fragSobel(v2f i) : SV_Target {
				half edge = Sobel(i);
				//分别计算背景为原图和纯色下的颜色值
				fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
				fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
				return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
 			}

            ENDCG
        }
    }
    
    FallBack Off
}
