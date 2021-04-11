Shader "CC/PostProcessing/PostProcessing_AddUVColor"
{
    //后处理效果：对当前缓冲区内的数据 * UV坐标最后显示
    //理解UV坐标 左下角为（0,0）右上角为(1,1)


	Properties
	{
		_MainTex("Texture",2D) = "white"{}//经过Graphics.Blit函数，该图片中储存了颜色缓冲区的数据
	}

		SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = tex2D(_MainTex,i.uv);
				col *= fixed4(i.uv.r, i.uv.g, 1, 1);//不仅输出纹理本身，而且还要将它乘上uv坐标
                return col;
            }
            ENDCG
        }
    }
}
