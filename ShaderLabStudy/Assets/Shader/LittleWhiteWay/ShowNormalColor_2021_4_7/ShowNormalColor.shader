
Shader "CC/LittleWhiteWay/ShowNormalColor"
{
    //根据顶点法线映射并输出成颜色
    Properties
    {
        _Color("颜色",Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //全局变量
            fixed4 _Color;//需要与前面的定义的名字相对应
            
            //模型中的数据（MeshRender组件）给顶点数据的结构体
            struct appdata
            {
                float4 pos : POSITION; //POSITION语义告诉Unity,将模型的顶点坐标填充与参数pos绑定
				float3 normal : NORMAL;//NORMAL语义告诉Unity,将模型空间的顶点法线与normal绑定
                float2 uv : TEXCOORD0;//TEXCOORD0语义告诉Unity,把贴图的UV坐标与uv绑定
            };

            //顶点数据给片元数据的结构体
            struct v2f
            {
                float4 sv_pos : SV_POSITION;//SV_POSITION语义告诉Unity,模型顶点在裁剪空间的坐标 与sv_pos绑定
                fixed3 color :COLOR0;//COLOR0语义告诉Unity,color用于存储颜色信息
            };

            v2f vert (appdata v) 
            {             
                v2f o;
                o.sv_pos = UnityObjectToClipPos(v.pos);//将模型顶点的物体坐标→世界坐标→视图坐标→裁剪坐标
                o.color = v.normal*0.5 + fixed3(0.5,0.5,0.5);//将法线方向映射到颜色中(法线矢量范围[-1,1],因此做一个映射计算)  
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {  
                fixed3 c = i.color;  
                //使用定义的颜色属性控制输出的颜色值
                c *= _Color.rgb;
                return fixed4(c,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
