Shader "CC/ShowTexture/ShowTwoFace"
{
    //学习多pass渲染
	//学习CGINCLUDE ENDCG语句 可以把之间的代码会被插入到所有Pass中，达到一次定义，多次使用的目的
	//包含变量声明、结构体定义、函数实现  不包含Blend语句、Zwrite语句
	//学习Cull Off  关闭背面剔除  Cull Back 剔除背面   Cull Front 剔除前面
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SecondTex ("SecondTex", 2D) = "white" {}
    }
    SubShader
    { 
		//使用透明度混合（Alpha Blending）时需要用Transparent
        Tags { "Queue"="Transparent" }

		CGINCLUDE
		sampler2D _MainTex;
		sampler2D _SecondTex;

		struct appdata
        {
            float4 vertex : POSITION;//模型的顶点坐标
            float2 uv : TEXCOORD0;//贴图的UV1坐标
        };

        struct v2f
        {
            float2 uv : TEXCOORD1;//贴图的UV2坐标
            float4 vertex : SV_POSITION;//裁剪空间的坐标
        };

		v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
            return o;
        }

		ENDCG

        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back //关闭背面裁剪
			//使用透明度混合时需要关闭深度写入
			ZWrite Off 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }

		Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Front //剔除前面的内容
			//使用透明度混合时需要关闭深度写入
			ZWrite Off 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_SecondTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
}
