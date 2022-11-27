using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Collectable_Starfish : MonoBehaviour
{
    private void OnTriggerStay2D(Collider2D other)
    {
        Rigidbody2D otherRB = other.GetComponent<Rigidbody2D>();
        string otherTag = other.gameObject.tag;

        if (otherRB != null &&
            otherTag == "PlayerShip")
        {
            Debug.Log($" - NOM NOM NOM");
            this.gameObject.SetActive(false);

            GameManager.Instance.IncreseScore();
        }
    }
}
