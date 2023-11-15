using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

/// <summary>
/// 屏幕后处理-运动模糊 可以让物体运动看起来更加真实平滑
/// 累计缓存的实现方式：对性能消耗很大 一般需要同一帧里渲染多次场景
/// 以下实现方式类似，但不需要一帧中把场景渲染多次 但需要保存之前的渲染结果，不断把当前的渲染图像叠加到之前的渲染图像中
/// 这种方法与原始的利用累计缓存的方法相比性能更好，但模糊效果可能会略有影响
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class MotionBlur : PostEffectBase
{
    public Shader motionBlurShader;
    private Material motionBlurMaterial;
    
    [Range(0f,0.9f)]
    public float blurAmount = 0.5f; //模糊参数 值越大 运动拖尾的效果就越明显 为了防止拖尾效果完全替代当前帧的渲染结果 值截取在0~0.9

    private RenderTexture accumulationTexture;
    
    public Material material
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }
    
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            if (accumulationTexture == null || accumulationTexture.width != src.width || accumulationTexture.height != src.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = new RenderTexture(src.width, src.height, 0);
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(src,accumulationTexture);
            }
            accumulationTexture.MarkRestoreExpected();
            material.SetFloat("_BlurAmount",1.0f - blurAmount);
            Graphics.Blit(src,accumulationTexture,material);
            Graphics.Blit(accumulationTexture,dest);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
