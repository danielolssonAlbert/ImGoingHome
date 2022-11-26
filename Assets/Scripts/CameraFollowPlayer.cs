using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollowPlayer : MonoBehaviour
{
    GameObject followObject;

    float maxHorizontal = 15.0f;

    // Start is called before the first frame update
    void Start()
    {
        followObject = GameObject.FindGameObjectWithTag("PlayerShip");
    }

    // Update is called once per frame
    void Update()
    {
        if (followObject == null)
        {
            return;
        }

        float newPosX = Mathf.Clamp(followObject.transform.position.x, -maxHorizontal, maxHorizontal);
        float newPosY = this.gameObject.transform.position.y;
        float newPosZ = followObject.transform.position.z;

        this.gameObject.transform.position = new Vector3(newPosX, newPosY, newPosZ);
    }
}
