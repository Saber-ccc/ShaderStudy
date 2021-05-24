Shader "CC/ShowTexture/ShowOverlap_BgTwist"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
		_OverlapTex ("Overlap Texture", 2D) = "white" {}
        _BGTex ("BG Texture", 2D) = "white" {}
        _Magnitude("强度",Range(0,1)) = 0
    }
    SubShader
    { 
		//使用透明度混合（Alpha Blending）时需要用Transparent
        Tags { "Queue"="Transparent" }

		CGINCLUDE
		sampler2D _MainTex;
		sampler2D _OverlapTex;
        sampler2D _BGTex;

		struct appdata
        {
            float4 vertex : POSITION;//模型的顶点坐标
            float2 uv : TEXCOORD0;//贴图的UV1坐标
        };

        struct v2f
        {
            float2 uv : TEXCOORD1;//贴图的UV2坐标
            float4 vertex : SV_POSITION;//裁剪空间的坐标
        };

		v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
            return o;
        }

		ENDCG

        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off //背面剔除
			//使用透明度混合时需要关闭深度写入
			ZWrite Off 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }

		Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Front //剔除前面的内容
			//使用透明度混合时需要关闭深度写入
			ZWrite Off 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_OverlapTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
}
