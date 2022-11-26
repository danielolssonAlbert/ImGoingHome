using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Obsticle_WaterSteam : MonoBehaviour
{
    public float waterForce;

    private void OnTriggerStay2D(Collider2D other)
    {
        Rigidbody2D otherRB = other.GetComponent<Rigidbody2D>();

        if (otherRB != null)
        {
            Debug.Log($" - PUSHING! PUUUUUSH");
            otherRB.AddForce(Vector2.left * waterForce);
        }
    }
}
