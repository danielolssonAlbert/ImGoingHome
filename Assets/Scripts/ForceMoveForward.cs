using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForceMoveForward : MonoBehaviour
{
    public Rigidbody2D playerRocketRB2D;
    
    public float transferSpeed = 1.0f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        playerRocketRB2D.AddRelativeForce(Vector3.forward * transferSpeed);
    }
}
