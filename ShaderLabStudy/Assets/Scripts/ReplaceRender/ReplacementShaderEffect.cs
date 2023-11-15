using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReplacementShaderEffect : MonoBehaviour
{
    public Color color;//定义颜色属性 给OverDrawEffect.shader赋予属性

    public Texture2D textureOpaque;
    public Texture2D textureTransparent;

    public Shader ReplacementShader;

    private void OnValidate()
    {
        Shader.SetGlobalColor("_OverDrawColor", color);//Shader.Set系列的方法都是你在代码中给shader赋值的好朋友

        Shader.SetGlobalTexture("_OpaqueTex", textureOpaque);
        Shader.SetGlobalTexture("_TransparentTex", textureTransparent);
    }

    private void OnEnable()
    {
        if (ReplacementShader != null)
            GetComponent<Camera>().SetReplacementShader(ReplacementShader, "RenderType");
        //if (ReplacementShader != null)
        //    GetComponent<Camera>().SetReplacementShader(ReplacementShader, "");
    }

    private void OnDisable()
    {
        GetComponent<Camera>().ResetReplacementShader();
    }
}
