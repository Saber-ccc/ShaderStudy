using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

/// <summary>
/// 屏幕后处理-高斯模糊
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class GaussianBlur : PostEffectBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial;

    [Range(0,4)]
    public int iterations = 1;//迭代次数
    [Range(0.2f,3)]
    public float blurSpread = 0.6f;//模糊范围 每次迭代的模糊扩散-值越大意味着模糊越多
    [Range(1,8)]
    public int downSample = 2;//缩放系数 越大需要处理的像素数越少，但过大会使图像像素化

    public Material material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }
    
    //第一个版本
    // private void OnRenderImage(RenderTexture src, RenderTexture dest)
    // {
    //     if (material != null)
    //     {
    //         int rtW = src.width;
    //         int rtH = src.height;
    //         //GetTemporary 分配一块与屏幕图像大小相同的缓冲区
    //         RenderTexture buffer = RenderTexture.GetTemporary(rtW,rtH,0);
    //         
    //         //高斯模糊需要调用两个pass 需要一块中间缓存buffer来存储第一个pass执行完毕得到的模糊效果
    //         Graphics.Blit(src,buffer,material,0);//使用竖直方向的一维高斯核进行滤波
    //         Graphics.Blit(buffer,dest,material,1);//使用水平方向的一维高斯核进行滤波
    //         RenderTexture.ReleaseTemporary(buffer);//释放
    //     }
    //     else
    //     {
    //         Graphics.Blit(src,dest);
    //     }
    // }
    
    //第二个版本 利用缩放对图像进行降采样 从而减少需要处理的像素个数 提高性能
    // void OnRenderImage(RenderTexture src, RenderTexture dest)
    // {
    //     if (material != null)
    //     {
    //         //使用了小于原屏幕分辨率的尺寸 这样需要处理的像素个数就是原来的几分之一
    //         int rtW = src.width / downSample;
    //         int rtH = src.height / downSample;
    //         RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
    //         buffer.filterMode = FilterMode.Bilinear; //滤波模式改为双线性 
    //
    //         Graphics.Blit(src, buffer, material, 0);
    //         Graphics.Blit(buffer, dest, material, 1);
    //
    //         RenderTexture.ReleaseTemporary(buffer); //释放
    //     }
    // }


    //最后一个版本 利用缩放对图像进行降采样 从而减少需要处理的像素个数 提高性能
    //还考虑了高斯模糊的迭代次数
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            //使用了小于原屏幕分辨率的尺寸 这样需要处理的像素个数就是原来的几分之一
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear; //滤波模式改为双线性 
        
            Graphics.Blit(src,buffer0);

            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW,rtH,0);
                
                Graphics.Blit(buffer0,buffer1,material,0);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 1);
                Graphics.Blit(buffer0, buffer1, material, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            Graphics.Blit(buffer0,dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
