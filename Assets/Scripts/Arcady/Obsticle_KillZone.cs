using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Obsticle_KillZone : MonoBehaviour
{
    private void OnCollisionEnter2D(Collision2D other)
    {
        Debug.Log($" - OnCollisionEnter2D!");
        string otherTag = other.gameObject.tag;

        if (otherTag == "PlayerShip")
        {
            Debug.Log($" - FAK ending game!");
            GameManager.Instance.DisplayLoose();
        }
    }
}
