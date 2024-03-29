using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

/// <summary>
/// 屏幕后处理-雾  使用噪声
/// 使用后处理来模拟雾、自由度较高、可以方便模拟各种无效（均匀的雾效、基于距离的线性、指数雾效、基于高度的雾效）
/// 相同高度时，雾的浓度一样，因此使用噪声来模拟不均匀雾效
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class FogWithNoise : PostEffectBase
{
	public Shader fogShader;
	private Material fogMaterial = null;

	public Material material
	{
		get
		{
			fogMaterial = CheckShaderAndCreateMaterial(fogShader, fogMaterial);
			return fogMaterial;
		}
	}

	private Camera myCamera;

	public Camera camera
	{
		get
		{
			if (myCamera == null)
			{
				myCamera = GetComponent<Camera>();
			}

			return myCamera;
		}
	}

	private Transform myCameraTransform;

	public Transform cameraTransform
	{
		get
		{
			if (myCameraTransform == null)
			{
				myCameraTransform = camera.transform;
			}

			return myCameraTransform;
		}
	}

	[Range(0.0f, 3.0f)] public float fogDensity = 1.0f; //雾浓度

	public Color fogColor = Color.white; //雾颜色

	public float fogStart = 0.0f; //雾效起始高度
	public float fogEnd = 2.0f; //雾效终止高度

	public Texture noiseTexture;

	[Range(-0.5f, 0.5f)] public float fogXSpeed = 0.1f;
	[Range(-0.5f, 0.5f)] public float fogYSpeed = 0.1f;
	
	[Range(0.0f, 3.0f)] public float noiseAmount = 1f;//控制噪声程度 0为不用噪声
	
	void OnEnable()
	{
		camera.depthTextureMode |= DepthTextureMode.Depth;
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null) {
			Matrix4x4 frustumCorners = Matrix4x4.identity;
			
			float fov = camera.fieldOfView;
			float near = camera.nearClipPlane;
			float aspect = camera.aspect;
			
			float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
			Vector3 toRight = cameraTransform.right * halfHeight * aspect;
			Vector3 toTop = cameraTransform.up * halfHeight;
			
			Vector3 topLeft = cameraTransform.forward * near + toTop - toRight;
			float scale = topLeft.magnitude / near;
			
			topLeft.Normalize();
			topLeft *= scale;
			
			Vector3 topRight = cameraTransform.forward * near + toRight + toTop;
			topRight.Normalize();
			topRight *= scale;
			
			Vector3 bottomLeft = cameraTransform.forward * near - toTop - toRight;
			bottomLeft.Normalize();
			bottomLeft *= scale;
			
			Vector3 bottomRight = cameraTransform.forward * near + toRight - toTop;
			bottomRight.Normalize();
			bottomRight *= scale;
			
			frustumCorners.SetRow(0, bottomLeft);
			frustumCorners.SetRow(1, bottomRight);
			frustumCorners.SetRow(2, topRight);
			frustumCorners.SetRow(3, topLeft);
			
			material.SetMatrix("_FrustumCornersRay", frustumCorners);

			material.SetFloat("_FogDensity", fogDensity);
			material.SetColor("_FogColor", fogColor);
			material.SetFloat("_FogStart", fogStart);
			material.SetFloat("_FogEnd", fogEnd);

			material.SetTexture("_NoiseTex", noiseTexture);
			material.SetFloat("_FogXSpeed", fogXSpeed);
			material.SetFloat("_FogYSpeed", fogYSpeed);
			material.SetFloat("_NoiseAmount", noiseAmount);

			Graphics.Blit (src, dest, material);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
