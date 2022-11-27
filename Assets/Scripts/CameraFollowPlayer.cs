using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollowPlayer : MonoBehaviour
{
    GameObject followObject;
    Camera thisCamera;

    public RectTransform boundery;

    public float maxHorizontal = 15.0f;
    public float maxVertical = 15.0f;

    // Start is called before the first frame update
    void Start()
    {
        followObject = GameObject.FindGameObjectWithTag("PlayerShip");
        thisCamera = GetComponent<Camera>();

        maxHorizontal = (boundery.rect.width/2.0f);
        maxVertical = (boundery.rect.height/2.0f);
    }

    // Update is called once per frame
    void Update()
    {
        if (followObject == null)
        {
            return;
        }

        float newPosX = Mathf.Clamp(followObject.transform.position.x, -maxHorizontal, maxHorizontal);//followObject.transform.position.x;
        float newPosY = Mathf.Clamp(followObject.transform.position.y, -maxVertical, maxVertical);//followObject.transform.position.x;
        /*
        float newPosY = this.gameObject.transform.position.y;

        if (followObject.transform.position.y > this.gameObject.transform.position.y)
        {
            newPosY = followObject.transform.position.y;
        }
        */
        float newPosZ = this.gameObject.transform.position.z;

        this.gameObject.transform.position = new Vector3(newPosX, newPosY, newPosZ);

        Vector3 playerScreenPos = thisCamera.WorldToScreenPoint(followObject.transform.position);

        if (playerScreenPos.y < 0.0f ||
            playerScreenPos.x < 0.0f ||
            playerScreenPos.x > Screen.width
            )
        {
            GameManager.Instance.DisplayLoose();
        }
    }
}
