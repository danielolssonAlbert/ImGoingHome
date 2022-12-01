using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollowPlayer : MonoBehaviour
{
    GameObject followObject;
    Camera thisCamera;

    public RectTransform boundery;

    float checkDepth = 50.0f;

    // Start is called before the first frame update
    void Start()
    {
        followObject = GameObject.FindGameObjectWithTag("PlayerShip");
        checkDepth = Mathf.Abs(transform.position.z);
        thisCamera = GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        if (followObject == null)
        {
            return;
        }

        float newPosX = followObject.transform.position.x;
        float newPosY = followObject.transform.position.y;
        float newPosZ = this.gameObject.transform.position.z;

        Vector3 newPos = new Vector3(newPosX, newPosY, newPosZ);
        
        this.gameObject.transform.position = ValidateTowardsBoundery(newPos);

        Vector3 playerScreenPos = thisCamera.WorldToScreenPoint(followObject.transform.position);

        if (playerScreenPos.y < 0.0f ||
            playerScreenPos.x < 0.0f ||
            playerScreenPos.x > Screen.width
            )
        {
            GameManager.Instance.DisplayLoose();
        }
    }

    Vector3 ValidateTowardsBoundery(Vector3 newPos)
    {
        Vector3 result = newPos;
        Vector3 cashedOldPos = this.gameObject.transform.position;

        // Predict fustrum
        thisCamera.gameObject.transform.position = newPos;

        Vector3 cameraLowerLeftCorner = thisCamera.ScreenToWorldPoint(new Vector3(0.0f, 0.0f, checkDepth)); 
        Vector3 cameraUpperRightCorner = thisCamera.ScreenToWorldPoint(new Vector3(Screen.width, Screen.height, checkDepth));

        Vector2 bounderyLowerLeftCorner = boundery.rect.position;
        Vector2 bounderyUpperRightCorner = boundery.rect.position + boundery.sizeDelta;

        // Check X
        if (cameraLowerLeftCorner.x < bounderyLowerLeftCorner.x ||
            cameraUpperRightCorner.x > bounderyUpperRightCorner.x)
        {
            result.x = cashedOldPos.x;
        }
        
        // Check Y
        if (cameraLowerLeftCorner.y < bounderyLowerLeftCorner.y ||
            cameraUpperRightCorner.y > bounderyUpperRightCorner.y)
        {
            result.y = cashedOldPos.y;
        }

        return result;
    }
}
