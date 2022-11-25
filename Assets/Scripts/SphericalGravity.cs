using UnityEngine;
using System.Collections;
using System.Collections.Generic;
 
public class SphericalGravity : MonoBehaviour {
 
    public List<GameObject> objects;
    public GameObject planet;
    public GameObject playerShip;
 
    public float gravitationalPull;
    public float soiFactor = 3.0f;

    private void Start()
    {
        playerShip = GameObject.FindGameObjectWithTag("PlayerShip");
    }

    void OnDrawGizmos()
    {
        if (gravitationalPull >= 0.0f)
        {
            Gizmos.color = Color.green;
        }
        else
        {
            Gizmos.color = Color.red;
        }

        Gizmos.DrawWireSphere(transform.position, Mathf.Abs(gravitationalPull) * this.transform.localScale.x * soiFactor);
    }

    void FixedUpdate() {

        float distancePlanetToPlayer = Vector3.Distance(planet.transform.position, playerShip.transform.position);

        float gravitationalPullScaled = gravitationalPull*this.transform.localScale.x*soiFactor;

        if (distancePlanetToPlayer < gravitationalPullScaled)
        {
            if (objects.Contains(playerShip) == false)
            {
                Debug.Log($" - Ship is ENTERING SOI");
                objects.Add(playerShip);
            }
        }
        
        if (distancePlanetToPlayer >= gravitationalPullScaled)
        {
            if (objects.Contains(playerShip) == true)
            {
                Debug.Log($" - Ship is LEAVING SOI");
                objects.Remove(playerShip);
            }
        }

        //apply spherical gravity to selected objects (set the objects in editor)
        foreach (GameObject o in objects) {
            Rigidbody rb = o.GetComponent<Rigidbody>();
            if( rb != null )
            {
                rb.AddForce((planet.transform.position - o.transform.position).normalized * gravitationalPull);
            }
        }
        /*
        //or apply gravity to all game objects with rigidbody
        foreach (GameObject o in UnityEngine.Object.FindObjectsOfType<GameObject>()) {
            
            Rigidbody rb = o.GetComponent<Rigidbody>();

            if(rb != null && o != planet){
                rb.AddForce((planet.transform.position - o.transform.position).normalized * gravitationalPull);
            }
        }
        */
    }
 
}