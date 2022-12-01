using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FixedCameraRatio : MonoBehaviour
{
    public float horizontalFoV = 30.0f;

    void Start(){
        float screenAspect = (float)Screen.width/(float)Screen.height;
        
        // 16:9 - Portrait  - 0.5625
        // 16:9 - Landscape - 1.777778;

        if ( screenAspect < 1.0f )
        {
            // Portrait
            GetComponent<Camera>().fieldOfView = horizontalFoV;
            return;
        }
        
        // Landscape
        float verticalFoV = Camera.HorizontalToVerticalFieldOfView(horizontalFoV, screenAspect);
        GetComponent<Camera>().fieldOfView = verticalFoV;
            
        return;

    }
}
