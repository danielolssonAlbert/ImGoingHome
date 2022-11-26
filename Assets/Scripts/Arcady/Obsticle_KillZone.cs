using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Obsticle_KillZone : MonoBehaviour
{
    private void OnCollisionEnter2D(Collider2D other)
    {
        string otherTag = other.tag;

        if (otherTag != "PlayerShip")
        {
            Debug.Log($" - FAK ending game!");
        }
    }
}
