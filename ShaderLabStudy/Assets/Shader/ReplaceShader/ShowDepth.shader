Shader "CC/ReplaceShader/ShowDepth"
{
	//shader替换，根据不同的RenderType 渲染两种不同的texture
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float depth : DEPTH;
            };

            half4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.depth = -mul(UNITY_MATRIX_MV,v.vertex).z * _ProjectionParams.w;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float invert = 1 - i.depth;

                return float4(invert,invert,invert,1)*_Color;
            }
            ENDCG
        }
    }

    SubShader
    {
        tags { "rendertype"="transparent" }

        Pass
        {

            ZWrite Off //关闭深度写入
            Blend SrcAlpha OneMinusSrcAlpha //开启混合模式
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            half4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
