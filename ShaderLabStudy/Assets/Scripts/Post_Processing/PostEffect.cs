using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]//表示可以在Edit Mode中观察Game窗口的执行
public class PostEffect : MonoBehaviour
{
    public Material material;

    //生命周期中，屏幕渲染的最后一个方法.
    //颜色缓冲区的内容真正被喷到屏幕上之前,修改缓冲区内容的最后机会
    //source：颜色缓冲区的数据
    //destination:输出到屏幕上的数据
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //用这个material把这个source渲染到那个destination
        Graphics.Blit(source, destination, material);
        //Graphics.Blit方法会把source传入的纹理赋值给mateiral中的主纹理,因此shader需要把主纹理命名为_MainTex
    }
}
