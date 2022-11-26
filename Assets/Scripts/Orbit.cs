using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Orbit : MonoBehaviour
{
    // orbits around a "star" at the origin with fixed mass
    //public float starMass = 1000f;
 
    public SphericalGravity orbitBody;
    public Transform orbitObject;
    //public Rigidbody orbitObjectRB;

    public Rigidbody thisRB;

    // Start is called before the first frame update
    void Start()
    {
        //orbitObjectRB = orbitObject.GetComponent<Rigidbody>();
        //orbitBody = orbitObject.GetComponent<SphericalGravity>();
        //thisRB = this.GetComponent<Rigidbody>();

        //InitialPushToOrbit_Simple();
        InitialPushToOrbit();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        //Orbit_Simple();
        Newton2ndLaw();
    }

    void Newton2ndLaw()
    {
        float r = Vector3.Distance(orbitObject.transform.position, this.transform.position);
        float totalForce = -(orbitBody.gravitationalPull * orbitBody.mass * thisRB.mass) / (r * r);
        Vector3 force = (this.transform.position - orbitObject.transform.position).normalized * totalForce;
        thisRB.AddForce(force);
    }

    void InitialPushToOrbit()
    {
        float initV = Mathf.Sqrt(2f * orbitBody.gravitationalPull * orbitBody.mass / thisRB.transform.position.magnitude);
        float escapeV = Mathf.Sqrt(4f * orbitBody.gravitationalPull * orbitBody.mass / thisRB.transform.position.magnitude);
        thisRB.velocity += new Vector3(0, 0, initV);
    }
    
    /*
    // Simplified
    void InitialPushToOrbit_Simple() {
        float initV = Mathf.Sqrt(starMass / transform.position.magnitude);
        GetComponent<Rigidbody>().velocity = new Vector3(0, 0, initV);
    }
 
    void Orbit_Simple() {
        float r = Vector3.Magnitude(transform.position);
        float totalForce = -(starMass) / (r * r);
        Vector3 force = (transform.position).normalized * totalForce;
        GetComponent<Rigidbody>().AddForce(force);
    }
    */
}
