using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 屏幕后处理-调节屏幕亮度、饱和度、对比度
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class BrightnessSaturationAndContrast : PostEffectBase
{
    public Shader briSatConShader;
    private Material briSatConMaterial;

    [Range(0,3)]
    public float brightness = 1;
    [Range(0,3)]
    public float saturation = 1;
    [Range(0,3)]
    public float contrast = 1;

    public Material material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
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
            material.SetFloat("_Brightness",brightness);
            material.SetFloat("_Saturation",saturation);
            material.SetFloat("_Contrast",contrast);
            
            Graphics.Blit(src,dest,material);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
