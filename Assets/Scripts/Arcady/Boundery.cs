using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Boundery : MonoBehaviour
{
    RectTransform thisRectTransform;

    Vector2 LowerLScreen;
    Vector2 UpperRScreen;

    Camera mainCamera;

    void Start()
    {
        mainCamera = GameObject.FindGameObjectWithTag("MainCamera").GetComponent<Camera>();

        if (mainCamera == null)
        {
            Debug.LogError($"Camera not found!");
            return;
        }

        thisRectTransform = GetComponent<RectTransform>();
        
        if (thisRectTransform == null)
        {
            Debug.LogError($"RectTransform not found!");
            return;
        }

        LowerLScreen = mainCamera.WorldToScreenPoint(thisRectTransform.rect.position);
    }

}
