using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 屏幕后处理-边缘检测 使用Sobel算子
/// 这种直接利用颜色信息进行边缘检测 会产生我们不需要的边缘线 如阴影、物体的纹理
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class EdgeDetection : PostEffectBase
{
    public Shader edgeDetectionShader;
    private Material edgeDetectionMaterial;

    [Range(0,1)]
    public float edgeOnly = 1;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    public Material material
    {
        get
        {
            edgeDetectionMaterial = CheckShaderAndCreateMaterial(edgeDetectionShader, edgeDetectionMaterial);
            return edgeDetectionMaterial;
        }
    }

    protected void Start()
    {
        CheckResources();
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly",edgeOnly);
            material.SetColor("_EdgeColor",edgeColor);
            material.SetColor("_BackgroundColor",backgroundColor);
            
            Graphics.Blit(src,dest,material);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
