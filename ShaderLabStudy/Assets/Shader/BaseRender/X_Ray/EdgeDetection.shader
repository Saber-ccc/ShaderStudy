Shader "CC/X_Ray/EdgeDetection"
{
    //实现边缘检测 
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            
            ZTest Always
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;//获取法向量
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //将法线从顶点空间转换为世界空间
                o.normal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                //将顶点从模型空间转换为世界空间
                //将两个值相减获得一个标准化的视角方向向量 模型顶点指向摄像机
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.vertex).xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //边缘部分是最深色，这是因为边缘点的法线与视角方向垂直，点乘结果接近1
                //float ndotV = dot(i.normal,i.viewDir);
                float ndotV =1 - dot(i.normal,i.viewDir)*2;
                return float4(ndotV,ndotV,ndotV,0);
            }
            ENDCG
        }
    }
}
