using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Collectable_Nest : MonoBehaviour
{
    public GameObject hintObject;

    private void OnTriggerEnter2D(Collider2D other)
    {
        Rigidbody2D otherRB = other.GetComponent<Rigidbody2D>();
        string otherTag = other.gameObject.tag;

        if (otherRB != null &&
            otherTag == "PlayerShip")
        {
            if (GameManager.Instance.starFishesCollected < 10)
            {
                if (hintObject.activeSelf == false)
                {
                    hintObject.SetActive(true);
                }
                return;
            }

            hintObject.SetActive(false);
            GameManager.Instance.DisplayWin();
        }
    }

    private void OnTriggerExit2D(Collider2D other)
    {
        string otherTag = other.gameObject.tag;

        if (otherTag == "PlayerShip")
        {
            if (hintObject.activeSelf == true)
            {
                hintObject.SetActive(false);
            }
        }
    }
}
