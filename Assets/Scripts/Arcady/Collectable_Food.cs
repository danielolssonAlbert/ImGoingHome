using System.Collections;
using UnityEngine;

public class Collectable_Food : MonoBehaviour
{
    public ParticleSystem collectPS;

    Rigidbody2D otherRB;
    string otherTag;

    private void OnTriggerStay2D(Collider2D other)
    {
        otherRB = other.GetComponent<Rigidbody2D>();
        otherTag = other.gameObject.tag;
        
        if (otherRB != null &&
            otherTag == "PlayerShip")
        {
            StartCoroutine(ShutdownSequence());
        }
    }

    private IEnumerator ShutdownSequence()
    {
        collectPS.Play();
        yield return new WaitForSeconds(0.20f);
        
        GameManager.Instance.IncreseScore();
        Debug.Log($" - NOM NOM NOM");
        this.gameObject.SetActive(false);
    }
}
