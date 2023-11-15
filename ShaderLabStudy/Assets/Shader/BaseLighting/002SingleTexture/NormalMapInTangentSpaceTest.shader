// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// 学习 法线纹理 通过在切线空间计算光照
// 使用逐像素光照 BlinnPhong模型高光 半兰伯特模型漫反射 及 环境光
// 从性能上来说逐顶点优于逐象素 毕竟顶点比像素少的多

Shader "ShaderEnter/002SingleTexture/NormalMapInTangentSpaceTest"
{
	Properties{
                [Normal]
		_BumpMap("法线贴图",2D) = "bump"{}
		_BumpScale("法线贴图强度",Range(-2.0,2.0)) = -1.0
		[Toggle(_ShowTry_Key)] _ShowTry_Key("显示法线结果",Float) = 0
	}
		SubShader{
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#pragma shader_feature _ShowTry_Key
			sampler2D _BumpMap;
			float _BumpScale;


			//Appction To Vertex
			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 uv:TEXCOORD0;
			};
			//Vertex To Fragment
			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				//图一UV值:图片位置第一个坐标频道*图片+图片的偏移
				o.uv = v.uv;

				//求副切线：法线和切线的点乘得到了副切线方向有两个，用*w分量来选择正面
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
				//求切线空间矩阵:
				//这里的切线、副切线、法线相当于xyz 这三个分量的组合就是这个空间的空间矩阵
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);

				//切线空间转换（顶点到灯光的朝向）
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				//切线空间转换（顶点到摄像机的朝向）
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			float4 frag(v2f i) :SV_TARGET{

			//切线空间下灯光的单位向量
			fixed3 tangentLightDir = normalize(i.lightDir);

			//切线空间下摄像机的单位向量
			fixed3 tangentViewDir = normalize(i.viewDir);

			//获取切线空间贴图法线
			fixed4 packedNormal = tex2D(_BumpMap,i.uv);

			//转换切线空间贴图法线（-1~1）
			fixed3 tangentNormal = UnpackNormal(packedNormal);
			
			//缩放法线强度
			tangentNormal.xy *= _BumpScale;

			//用的是切线空间下的法线纹理，因此法线的z为正数 其实(dot(xy,xy))=x*x+y*y
			//由于偏移后的法线是归一化的，因此满足x2 + y2 + z2 = 1
			//所以z=sqrt(1-(x2+y2))
			tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

			//灯光一颜色*环境色*亮度(切线空间下的法线与切线下的灯光点乘得出)
			fixed3 diffuse =dot(tangentNormal, tangentLightDir);


			//光照输出
			float4 OutColor = float4(diffuse*0.5 + 0.5, 1);

			//开启法线输出
#ifdef _ShowTry_Key
					//输出法线最终结果
			OutColor = float4(tangentNormal*0.5 + 0.5, 1);

#endif
			return OutColor;
			}
		ENDCG
	}
		}
}
