
// 学习 法线纹理 通过在世界空间计算法线纹理
// 使用逐像素光照 BlinnPhong模型高光 半兰伯特模型漫反射 及 环境光
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/002SingleTexture/NormalMapInWorldSpace"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}//bump是内置的法线纹理
        _BumpScale ("Bump Scale", Float) = 1.0//控制凹凸程度，当为0时不会对光照产生任何影响
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0,256)) = 20
    }
    SubShader
    {
        Pass
        {
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; //纹理名_ST ST是缩放和平移的缩写  纹理名_ST.xy储存的是缩放值 纹理名_ST.zw储存的事偏移值
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale; //记一次bug， 法线不生效， 就是因为这个参数设的float4
            fixed4 _Specular;
            float _Gloss;
           
            struct a2v
            {
                float4 vertex : POSITION;//模型空间坐标
                float3 normal : NORMAL;//模型顶点法线
                float4 tangent : TANGENT;//模型顶点的切线方向
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
                //通常_MainTex和_BumpMap会使用同一组纹理坐标，出于减少插值寄存器的使用数目的
                float4 uv : TEXCOORD0;  //由于我们使用了两张纹理，需要储存两个纹理坐标 uv.xy储存_MainTex纹理坐标，uv.zw储存_BumpMap的纹理坐标
                //一个插值寄存器最多只能储存float4大小的变量
                //依次储存 切线空间到世界空间的变换矩阵的每一行 每行只需要使用float3即可 但为了充分利用寄存器空间 我们把世界空间顶点存在这3个的W分量中
                float4 TtoW0 : TEXCOORD1; 
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标
    
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
    
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
                
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w); 
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
             
                //获得法线贴图中的紋素
                fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy,bump.xy)));
                //将法线从切线空间变换到世界空间
                bump = normalize(half3(dot(i.TtoW0.xyz,bump), dot(i.TtoW1.xyz,bump), dot(i.TtoW2.xyz,bump)));
                
                fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;//使用纹理颜色作为漫反射颜色
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//获取环境光颜色
                
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(bump,lightDir));//计算漫反射
                
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(bump,halfDir)),_Gloss);
                
                return fixed4(ambient + diffuse + specular , 1.0);
            }
            ENDCG
        }
    }
    
    //FallBack "Specular"
}
