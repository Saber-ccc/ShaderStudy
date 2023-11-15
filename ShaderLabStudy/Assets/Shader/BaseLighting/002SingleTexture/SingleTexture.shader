
// 学习 纹理
// 使用逐像素光照 BlinnPhong模型高光 半兰伯特模型漫反射 及 环境光
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/002SingleTexture/SingleTexture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0,256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags { "LightModel"="ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; //纹理名_ST ST是缩放和平移的缩写  纹理名_ST.xy储存的是缩放值 纹理名_ST.zw储存的事偏移值
            fixed4 _Specular;
            float _Gloss;
           
            struct a2v
            {
                float4 vertex : POSITION;//模型空间坐标
                float3 normal : NORMAL;//模型顶点法线
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
                float3 worldNormal : TEXCOORD0;//也可以用TEXCOORD0
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));//获取世界空间光源方向 假设场景只有一个光源且是平行光

                fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;//使用纹理颜色作为漫反射颜色

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//获取环境光颜色
                
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));//计算漫反射
                //saturate 是CG提供的一种函数 作用是把参数截取到【0,1】的范围内

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));//获取世界空间下 顶点朝向摄像机的向量

                //BlinnPhong模型
                fixed3 halfDir = normalize(worldLightDir + viewDir);//这里不用除2 是因为不需要他的长度，只需要方向 
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);//计算高光

                return fixed4(ambient + diffuse + specular,1.0);
            }

            ENDCG
        }
    }
    
    FallBack "Specular"
}
