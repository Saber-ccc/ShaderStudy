Shader "CC/Shadow/CustomPlayerShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ShadowInvLen ("ShadowInvLen", float) = 1.0 //0.4449261
		_Power("Power", Range(0,2)) = 1.7
    }
    SubShader
    {
        Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+10" }
		LOD 100

        Pass
        {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Power;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * _Power;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}

			ENDCG
        }

		Pass
		{
			Blend SrcAlpha  OneMinusSrcAlpha
			ZWrite Off
			Cull Back
			ColorMask RGB

			Stencil
			{
				Ref 0
				Comp Equal
				WriteMask 255
				ReadMask 255
				//Pass IncrSat
				Pass Invert
				Fail Keep
				ZFail Keep
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			float4 _ShadowPlane; //��Ⱦ�ĵ���
			float4 _ShadowProjDir; //��Ⱦ�Ĺ�Դ�㣬����ֻ�Ǽ�¼���λ�ã����ڼ�����Ӱ��ͶӰ
			float4 _WorldPos;
			float _ShadowInvLen; //��Ӱ�ĳ���
			float4 _ShadowFadeParams; //��Ӱ����Ĳ���

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 xlv_TEXCOORD0 : TEXCOORD0;
				float3 xlv_TEXCOORD1 : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;

				float3 lightdir = normalize(_ShadowProjDir); //��λ�����շ�������
				float3 worldpos = mul(unity_ObjectToWorld, v.vertex).xyz; //ģ������ת����������
				// _ShadowPlane.w = p0 * n  // ƽ���w��������p0 * n
				float distance = (_ShadowPlane.w - dot(_ShadowPlane.xyz, worldpos)) / dot(_ShadowPlane.xyz, lightdir.xyz); //������Ӱ�ĳ���
				worldpos = worldpos + distance * lightdir.xyz; //Ӱ�ӵ�ͶӰ��
				o.vertex = mul(unity_MatrixVP, float4(worldpos, 1.0));
				o.xlv_TEXCOORD0 = _WorldPos.xyz;
				o.xlv_TEXCOORD1 = worldpos;  //Ӱ��ͶӰ�ĵ���ɵ�����
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float3 posToPlane_2 = (i.xlv_TEXCOORD0 - i.xlv_TEXCOORD1);
				float4 color;
				color.xyz = float3(0.0, 0.0, 0.0);
				color.w = (pow((1.0 - clamp(((sqrt(dot(posToPlane_2, posToPlane_2)) * _ShadowInvLen) - _ShadowFadeParams.x), 0.0, 1.0)), _ShadowFadeParams.y) * _ShadowFadeParams.z);  //͸���Ƚ������
				return color;
			}

			ENDCG
		}
    }
}
