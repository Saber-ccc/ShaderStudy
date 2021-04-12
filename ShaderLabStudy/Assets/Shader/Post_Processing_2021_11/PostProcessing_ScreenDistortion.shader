Shader "CC/PostProcessing/PostProcessing_ScreenDistortion"
{
    Properties
    {
        _MainTex ("主纹理", 2D) = "white" {}
		_DisplacementTex("位移图",2D) = "white"{}
		_Magnitude("强度",Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
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
			sampler2D _DisplacementTex;
            float4 _MainTex_ST;
			float _Magnitude;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //_Time的参数，这个参数是写在了UnityCG.cginc文件
                //_Time.x返回的是当前的时间的20分之一，_Time.y则是当前时间
                fixed2 distUV = fixed2(i.uv.x + _Time.x*2 , i.uv.y + _Time.x*2);

				//纹理中红色的部分代表uv在x轴上的位移，而绿色则表示uv在y轴上的位移
				fixed2 disp = tex2D(_DisplacementTex,distUV).xy;//对位移图进行采样
															  
				//从uv中获取的值是介于0到1之间的，这样的数值算出来的扭曲效果会不明显，
				//所以要让值定位到-1到1之间，让界面有飘来飘去的感觉，并乘上magnitude让我们可以控制强度
				disp = ((disp * 2) - 1) *_Magnitude;

                fixed4 col = tex2D(_MainTex, i.uv+disp);
                return col;
            }
            ENDCG
        }
    }
}
