using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RanbowColour : MonoBehaviour
{
    private Renderer rend;

    private Material _material;
    // Start is called before the first frame update
    void Start()
    {
        rend = GetComponent<Renderer>();
        _material = rend.material;
        //该方法可以调用shader里的变量
        _material.SetColor("_Color",Color.cyan);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
