using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GreyTest : MonoBehaviour
{
    public Image image01;

    public Image image02;
    
    Color c1=new Color(0,1,1,1);
    Color c2=new Color(1,1,1,1);

    private int index = 0;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            if (index % 2 == 0)
            {
                image01.color = c1;
                image02.color = c1;
            }
            else
            {
                image01.color = c2;
                image02.color = c2;
            }

            index++;
        }
    }
}
