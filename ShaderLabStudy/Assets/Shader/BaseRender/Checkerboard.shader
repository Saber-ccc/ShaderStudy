Shader "CC/ShowColor/Checkerboard"
{
    //根据UV值显示颜色
    //理解UV坐标 左下角为（0,0）右上角为(1,1)
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            fixed checker(float2 uv)
            {
                float2 repeatUV = uv * 10;
                float2 c = floor(repeatUV) / 2; //floor 取整数部分
                float temp = frac(c.x + c.y) * 2;//frac 取小数部分
                return temp;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed col = checker(i.uv);
                return col;
            }
            ENDCG
        }
    }
}
