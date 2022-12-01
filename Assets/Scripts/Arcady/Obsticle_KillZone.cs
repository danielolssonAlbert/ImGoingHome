using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Obsticle_KillZone : MonoBehaviour
{
    private void OnCollisionEnter2D(Collision2D other)
    {
        string otherTag = other.gameObject.tag;

        if (otherTag == "PlayerShip")
        {
            GameManager.Instance.GetHit();
        }
    }
}
