using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SocialPlatforms;

public class EdgeDetection : PostEffectsBase
{
    public Shader edgeDetectShader;

    private Material edgeDetectMaterial = null;

    public Material material
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }

    [Range(0.0f, 1.0f)] 
    [Header("边缘线强度")]
    public float edgesOnly = 0.0f;
    
    [Header("描边颜色")]
    public Color edgeColor=Color.black;
    
    [Header("背景颜色")]
    public Color backgroundColor=Color.white;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly",edgesOnly);
            material.SetColor("_EdgeColor",edgeColor);
            material.SetColor("_BackgroundColor",backgroundColor);
            
            Graphics.Blit(src,dest,material);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
