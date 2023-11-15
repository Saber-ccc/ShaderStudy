
// 学习 法线纹理 通过在切线空间计算法线纹理
// 使用逐像素光照 BlinnPhong模型高光 半兰伯特模型漫反射 及 环境光
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/002SingleTexture/NormalMapInTangentSpace"
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
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);//矩阵变换，获得裁剪空间坐标
    
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
    
                //计算副切线 ：法线和切线的点乘得到了副切线方向有两个，用*w分量来选择正面
                float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
                //求切线空间矩阵:
				//这里的切线、副切线、法线相当于xyz 这三个分量的组合就是这个空间的空间矩阵
                float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
                //TANGENT_SPACE_ROTATION;//unity内置方法 模型空间到切线空间的矩阵
                     
                o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz; //切线空间转换（顶点到灯光的朝向）
                o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;//切线空间转换（顶点到摄像机的朝向）
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                //获得法线贴图中的紋素
                fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
                fixed3 tangentNormal;
                
                //或者将纹理标记为“法线贴图”，并使用内置函数
                tangentNormal = UnpackNormal(packedNormal);//转换切线空间贴图法线（-1~1）
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
                
                fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;//使用纹理颜色作为漫反射颜色
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//获取环境光颜色
                
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));//计算漫反射
                
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss);
                
                return fixed4(ambient + diffuse + specular , 1.0);
            }
            ENDCG
        }
    }
    
    //FallBack "Specular"
}
