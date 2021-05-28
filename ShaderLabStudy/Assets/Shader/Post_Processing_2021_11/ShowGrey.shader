Shader "CC/ShowGrey"
{
    //效果 指定屏幕区域灰度图
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white" {}
        _Color ("Color", color) = (1,1,1,1)
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
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                o.screenPos = ComputeScreenPos (o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenPos = i.screenPos.xy/i.screenPos.w;
                screenPos.xy *= _ScreenParams.xy;
                 
				fixed4 col = tex2D(_MainTex,i.uv);
                
                //if(screenPos.x >435 && screenPos.x <2160 &&screenPos.y >13  &&screenPos.y <950 )
                //{
                //    float grey = dot(col.rgb, float3(0.299, 0.587, 0.114));
                //    col.rgb = float3(grey, grey, grey);   
                //}

                if(screenPos.x >0.185 * _ScreenParams.x && screenPos.x <0.923 * _ScreenParams.x &&screenPos.y >0.129 *_ScreenParams.y &&screenPos.y <0.879 *_ScreenParams.y)
                {
                    float grey = dot(col.rgb, float3(0.299, 0.587, 0.114));
                    col.rgb = float3(grey, grey, grey);   
                }
                return col;   
            }
            ENDCG
        }
    }
}
