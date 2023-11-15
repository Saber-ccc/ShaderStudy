using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 屏幕后处理-Bloom 较亮的区域扩散到周围的区域中，造成一种朦胧的效果
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class Bloom : PostEffectBase
{
    public Shader bloomShader;
    private Material bloomMaterial;
    
    [Range(0,4)]
    public int iterations = 1;//迭代次数
    [Range(0.2f,3)]
    public float blurSpread = 0.6f;//模糊范围 每次迭代的模糊扩散-值越大意味着模糊越多
    [Range(1,8)]
    public int downSample = 2;//缩放系数 越大需要处理的像素数越少，但过大会使图像像素化
    [Range(0f,4f)]
    public float luminanceThreshold = 0.6f; //亮度 如果开启HDR 图像亮度可能会超过1
    
    public Material material
    {
        get
        {
            bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
            return bloomMaterial;
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
            material.SetFloat("_LuminanceThreshold",luminanceThreshold);

            int rtW = src.width / downSample;
            int rtH = src.height / downSample;
            
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW,rtH,0);
            buffer0.filterMode = FilterMode.Bilinear;
            
            Graphics.Blit(src,buffer0,material,0);

            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 1);
                
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                
                Graphics.Blit(buffer0,buffer1,material,2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
       
            material.SetTexture("_Bloom", buffer0);
            Graphics.Blit(src,dest,material,3);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
