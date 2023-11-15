Shader "ShaderEnter/Light001_Lambert/Vertex_DiffuseReflash"
{
    //逐顶点漫反射
	//学习向量与矩阵的乘法顺序
	//向量*矩阵时（向量必须是横矩阵），矩阵*向量时（向量必须是列矩阵）
	//（AB）-1=B-1A-1
	//M正交 => MT = M-1     （矩阵的逆=矩阵的转置）c
    Properties
    {
        _Diffuse("光源颜色", Color) =(1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Pass
        {
			//定义光照模式，只有正确定光照模式，才能得到一些Unity内置光照变量
            Tags{"LightMode" = "ForwardBase"}
                
           

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

			//定义全局变量
			fixed4 _Diffuse;

            struct a2v
            {
                float4 vertex : POSITION;//获取物体坐标
                float2 normal : NORMAL;//获取法向量
            };

            struct v2f
            {
				fixed3 color : COLOR;
                float4 sv_Pos : SV_POSITION;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.sv_Pos = UnityObjectToClipPos(v.vertex);//从物体坐标转为裁剪坐标
                //漫反射公式：
                //漫反射的颜色值 = 入射光的颜色值 * 漫反射系数(物体表面粗糙程度) * 光反射的夹角与眼睛角度的夹角
                //C diffuse = (C light * M diffuse) * max（0，n * l）
                //C diffuse：C是color的缩写，diffuse是漫反射的意思，所以它代表漫反射的颜色值
                //C light：C同样是color的缩写，light代表入射光，所以它代表入射光的颜色值
                //M diffuse：漫反射系数
                //n^：表面法线
                //l^：光源的单位矢量

                //UNITY_LIGHTMODEL_AMBIENT :代表环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //根据3D数学基础的定义，向量*矩阵时（向量必须是横矩阵），矩阵*向量时（向量必须是列矩阵），顺序很关键，横竖矩阵通关转置就可以转换

                //worldNormal：该顶点所在物体表面的法线，可以理解为物体表面的朝向，对应的就是漫反射中的表面法线
                //unity_WorldToObject:把方向矢量从世界空间转换到模型空间中

                //mul( v.normal , (float3x3)unity_WorldToObject):有以下理解
                //首先 物体空间下的法线转为世界空间的法线表示为：mul(unity_objectToWorld,v.normalize)
                //但是用这种方式转变，会在不等比缩放的情况下，法线转换错误，没有垂直与切面
                //因此需要用他的转置：unity_objectToWorld的转置为unity_WorldToObject
                //这里有两个前提：
                //（1）V*M = Mt*Vt (Mt和Vt为转置矩阵)   
                //（2）向量*矩阵时，和向量是行矩阵；矩阵*向量时，向量是列矩阵；向量的转置就是通过改变乘法的顺序
                //在shaderlab中vertex默认是以列矩阵存在的，所以博客中我们要放在左边来乘必须要转置
                //mul(unity_objectToWorld,v.normalize)  = mul(v.normalize,unity_WorldToObject)
				fixed3 worldNormal = normalize(mul( v.normal , (float3x3)unity_WorldToObject) );

				//_WorldSpaceLightPos0：Lighting.cginc中定义的世界坐标指向光源的光照方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);


				//根据Lambert定律计算漫反射 saturate函数将所得矢量或标量的值限定在[0,1]之间
                //dot(worldNormal, worldLight):表示光源与法线之前的夹角情况 1为相同方向, 0 为垂直, -1为相反方向
                //_LightColor0：光颜色
                //_Diffuse:漫反射系数
				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal, worldLight));


                //最后我们计算出的漫反射光的颜色需要跟环境光相加得到最后的颜色值。
				o.color = diffuse + ambient;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				return fixed4(i.color,1.0);
            }
            ENDCG
        }
    }
}
