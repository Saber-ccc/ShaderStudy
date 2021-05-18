Shader "CC/ReplaceShader/OverDrawEffect"
{
    SubShader
    {
        //如果开启了ZWrite，那么Z数据则会被写入到Z-Buffer里面，并且CPU会优先调用ZBuffer中的值来进行深度判断。
        //而如果没有开启ZWrite，则会使用物体材质中的RenderQueue来判断深度
        Tags { "Queue"="Transparent" }

        //总结一下，ZTest是判断深度的前后以决定像素的去留，ZWrite是写入深度缓冲。
        //前者决定深度判断的流程，后者决定判断时用动态深度还是静态渲染类型来对比
        ZTest Always //像素永远通过深度测试
        ZWrite Off
        Blend One One

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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);//从物体坐标转为裁剪坐标
                return o;
            }

            //定义全局变量
            half4 _OverDrawColor;

            fixed4 frag (v2f i) : SV_Target
            {
                return _OverDrawColor;
            }
            ENDCG
        }
    }
}
