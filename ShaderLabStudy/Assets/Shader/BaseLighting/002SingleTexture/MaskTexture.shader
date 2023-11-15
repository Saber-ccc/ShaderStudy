
// 学习 遮罩纹理
// 使用逐像素光照 BlinnPhong模型高光 半兰伯特模型漫反射 及 环境光
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/002SingleTexture/MaskTexture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}//bump是内置的法线纹理
        _BumpScale ("Bump Scale", Float) = 1.0//控制凹凸程度，当为0时不会对光照产生任何影响
        _SpecularMask ("Specular Mask", 2D) = "white" {}
        _SpecularScale ("Specular Scale", Float) = 1.0
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
            float4 _MainTex_ST; //纹理名_ST ST是缩放和平移的缩写  纹理名_ST.xy储存的是缩放值 纹理名_ST.zw储存的事偏移值 当前3张贴图用同一个缩放平移值
            sampler2D _BumpMap;
            float _BumpScale; //记一次bug， 法线不生效， 就是因为这个参数设的float4
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;
           
            struct a2v
            {
                float4 vertex : POSITION;//模型空间坐标
                float3 normal : NORMAL;//模型顶点法线
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;//裁剪空间坐标
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
   
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
            
                TANGENT_SPACE_ROTATION;//unity内置方法 模型空间到切线空间的矩阵
                o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            //片元着色器中使用遮罩纹理
            fixed4 frag(v2f i):SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                //获得法线贴图中的紋素
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uv));//转换切线空间贴图法线（-1~1）
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
                
                fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;//使用纹理颜色作为漫反射颜色
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//获取环境光颜色
                
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));//计算漫反射
                
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

                //在这里我们选择使用r分量来计算掩码值，我们用得到的掩码值和_SpecularScale 相乘， 起来控制高光反射的强度。
                fixed specularMask = tex2D(_SpecularMask,i.uv).r * _SpecularScale;//获得遮罩值
                
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss) * specularMask;
                
                return fixed4(ambient + diffuse + specular , 1.0);
            }

            ENDCG
        }
    }
    
    FallBack "Specular"
}
