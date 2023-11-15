using UnityEngine;
using System.Collections;

/// <summary>
/// 运动模糊 通过深度图实现
/// 使用速度映射图、速度映射图存储了每个像素的速度，然后使用这个速度来决定模糊的方向和大小 生成速度映射图方法有多种
/// 当前方法利用深度纹理在片元着色器中为每个像素计算其在世界空间下的位置 计算前一阵与当前帧的位置差，生成该像素的速度
/// 优点是可以在一个屏幕后处理步骤中完成整个效果的模拟，缺点是需要在片元着色器中进行两次矩阵乘法的操作，对性能有所影响
/// </summary>
public class MotionBlurWithDepthTexture : PostEffectBase {

	public Shader motionBlurShader;
	private Material motionBlurMaterial = null;

	public Material material {  
		get {
			motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
			return motionBlurMaterial;
		}  
	}

	private Camera myCamera;
	public Camera camera {
		get {
			if (myCamera == null) {
				myCamera = GetComponent<Camera>();
			}
			return myCamera;
		}
	}

	[Range(0.0f, 1.0f)]
	public float blurSize = 0.5f;

	private Matrix4x4 previousViewProjectionMatrix;//上一帧摄像机的视角*投影矩阵
	
	void OnEnable() {
		camera.depthTextureMode |= DepthTextureMode.Depth;

		previousViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
	}
	
	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (material != null) {
			material.SetFloat("_BlurSize", blurSize);

			material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
			//来分别得到当前摄像的视角矩阵和投影矩阵。对它们相乘后取逆 得到当前帧的视角*投影矩阵的逆矩阵
			Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
			Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
			material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
			previousViewProjectionMatrix = currentViewProjectionMatrix;

			Graphics.Blit (src, dest, material);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
