using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 屏幕后处理基类
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectBase : MonoBehaviour
{

    protected void CheckResources()
    {
        bool isSupported = CheckSupport();
        if (!isSupported)
        {
            NotSupported();
        }
    }

    protected bool CheckSupport()
    {
        if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
        {
            Debug.LogWarning("当前平台不支持屏幕后处理");
            return false;
        }
        return true;
    }

    protected void NotSupported()
    {
        enabled = false;
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null) return null;
        if (shader.isSupported && material && material.shader == shader) return material;
        if (!shader.isSupported) 
            return null;
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
                return material;
            else
                return null;
        }
    }

    protected void Start()
    {
        CheckResources();
    }
}
