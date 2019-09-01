using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectsBase
{
    public Shader motionBlurShader;

    private Material motionBlurMaterial = null;

    public Material material
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    [Range(0.0f, 0.9f)]
    [Header("模糊参数")]
    public float blurAmount = 0.5f;
    
    [SerializeField]
    [Header("累积缓存")]
    private RenderTexture accumullationTexture;

    private void OnDisable()
    {
        DestroyImmediate(accumullationTexture);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            if (accumullationTexture == null || accumullationTexture.width != src.width ||
                accumullationTexture.height != src.height)
            {
                DestroyImmediate(accumullationTexture);
                accumullationTexture = new RenderTexture(src.width, src.height, 0);
                accumullationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(src, accumullationTexture);
            }
            //恢复操作 上一次的纹理未被清空或销毁 这一次又要用 使用恢复操作
            accumullationTexture.MarkRestoreExpected();

            material.SetFloat("_BlurAmount", 1.0f - blurAmount);
            
            Graphics.Blit(src, accumullationTexture, material);
            Graphics.Blit(accumullationTexture, dest);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
