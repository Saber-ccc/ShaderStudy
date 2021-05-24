Shader "CC/ReplaceShader/ShowDepth"
{
    //学习 定义一系列的子shader（SubShader）来让相机根据不同的对象进行不同的渲染方法，这种渲染被称之为替换渲染
    //学习摄像机的替换shader函数GetComponent<Camera>().SetReplacementShader(ReplacementShader, "RenderType");
    //将屏幕上的像素深度作为颜色输出，越远的像素越深色，距离相机越近的像素越浅色
    Properties{
	    _Color("Color", Color) = (1,1,1,1)
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
