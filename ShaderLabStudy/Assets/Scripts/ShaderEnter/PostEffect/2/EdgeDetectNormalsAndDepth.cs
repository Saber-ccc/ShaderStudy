using UnityEngine;
using System.Collections;

/// <summary>
/// 后处理-边缘检测 通过Roberts算子
/// 在深度和法线纹理上进行边缘检测 更可靠
/// </summary>
public class EdgeDetectNormalsAndDepth : PostEffectBase
{

	public Shader edgeDetectShader;
	private Material edgeDetectMaterial = null;

	public Material material
	{
		get
		{
			edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
			return edgeDetectMaterial;
		}
	}

	[Range(0.0f, 1.0f)] public float edgesOnly = 0.0f;//边缘线强度

	public Color edgeColor = Color.black;//边缘颜色

	public Color backgroundColor = Color.white;//背景颜色

	public float sampleDistance = 1.0f;//控制对深度+法线纹理采样时，使用的采样距离 值越大描边越宽

	public float sensitivityDepth = 1.0f;//深度值

	public float sensitivityNormals = 1.0f;//法线值

	void OnEnable()
	{
		GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
	}

	[ImageEffectOpaque] //不透明的Pass队列（<=2500）执行完毕后立即调用该函数，而不对透明物体产生影响
	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_EdgeOnly", edgesOnly);
			material.SetColor("_EdgeColor", edgeColor);
			material.SetColor("_BackgroundColor", backgroundColor);
			material.SetFloat("_SampleDistance", sampleDistance);
			material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));

			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
