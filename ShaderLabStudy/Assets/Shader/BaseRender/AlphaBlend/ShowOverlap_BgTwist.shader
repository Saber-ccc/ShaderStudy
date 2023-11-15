Shader "CC/ShowTexture/ShowOverlap_BgTwist"
{
    Properties
    {
        _BGTex ("BG Texture", 2D) = "white" {}
		_OverlapTex ("Overlap Texture", 2D) = "white" {}
        _TwistTex ("Twist Texture", 2D) = "white" {}
        _Magnitude("强度",Range(0,1)) = 0
    }
    SubShader
    { 
		//使用透明度混合（Alpha Blending）时需要用Transparent
        Tags { "Queue"="Transparent" }

		CGINCLUDE
		sampler2D _BGTex;
		sampler2D _OverlapTex;
        sampler2D _TwistTex;
		float _Magnitude;

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
				//_Time的参数，这个参数是写在了UnityCG.cginc文件
				//_Time.x返回的是当前的时间的20分之一，_Time.y则是当前时间
				fixed2 distUV = fixed2(i.uv.x + _Time.x * 2 , i.uv.y + _Time.x * 2);

				//纹理中红色的部分代表uv在x轴上的位移，而绿色则表示uv在y轴上的位移
				fixed2 disp = tex2D(_TwistTex,distUV).xy;//对位移图进行采样

				//从uv中获取的值是介于0到1之间的，这样的数值算出来的扭曲效果会不明显，
				//所以要让值定位到-1到1之间，让界面有飘来飘去的感觉，并乘上magnitude让我们可以控制强度
				disp = ((disp * 2) - 1) *_Magnitude;
				//fixed2 disp = tex2D(_TwistTex,i.uv).xy;
				
				fixed4 col = tex2D(_BGTex, i.uv + disp);

                return col;
            }
            ENDCG
        }

		Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back //剔除背面
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
