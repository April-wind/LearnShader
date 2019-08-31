using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase
{
    public Shader briSatConShader;

    private Material briSatConMaterial;

    public Material material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }

    [Range(0.0f,3.0f)]
    [Header("亮度")]
    public float brightness = 1.0f;

    [Range(0.0f, 3.0f)] 
    [Header("饱和度")]
    public float saturation = 1.0f;

    [Range(0.0f, 3.0f)] 
    [Header("对比度")]
    public float contrast = 1.0f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_Brightness",brightness);
            material.SetFloat("_Saturation",saturation);
            material.SetFloat("_Contrast",contrast);

            Graphics.Blit(src, dest, material);//src会传递给Shader里的_MainTex
        }
        else
        {
            //如果材质不可用 直接把原图像显示到屏幕上
            Graphics.Blit(src,dest);
        }
    }
}
