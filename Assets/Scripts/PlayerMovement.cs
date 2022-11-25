using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IGH.Movement
{
    public class PlayerMovement : MonoBehaviour
    {
        public bool isOrbiting = false;
        public bool isInOrbit = false;
        public bool isTransferring = false;

        public Transform orbitBody;

        public Transform playerRocket;
        public Rigidbody playerRocketRB;

        public float transferSpeed = 1.0f;
        public float orbitSpeed = 3.0f;
        public float orbitDistance = 3.0f;
        
        public Button ThrustButton;

        public GameObject retroPS;
        public GameObject proPS;

        private void Start()
        {
            playerRocketRB.velocity = (Vector3.forward * 5.0f);
        }

        void Update()
        {
            // Always look at VectorHeading
            Vector3 lookAhead = ((playerRocketRB.transform.position - playerRocketRB.transform.position+playerRocketRB.velocity).normalized * 3.0f);
            lookAhead += playerRocketRB.transform.position;
            playerRocket.LookAt(lookAhead);;
            /*
            if (isTransferring == true)
            {
                Transfer();
                return;
            }

            if (isOrbiting == false)
            {
                this.transform.position = orbitBody.position;
                playerRocket.localPosition = new Vector3(orbitDistance, 0, 0);

                isOrbiting = true;
                return;
            }

            Rotate();
            */
        }
        void OnDrawGizmos()
        {
            Gizmos.color = Color.blue;
            Vector3 lookAhead = ((playerRocketRB.transform.position - playerRocketRB.transform.position+playerRocketRB.velocity).normalized * 3.0f);
            lookAhead += playerRocketRB.transform.position;
            Gizmos.DrawWireSphere(lookAhead, 1.0f);
        }

        private void OnCollisionEnter(Collision collision)
        {
            // Hiting new Planet SOI
        }

        private void OnCollisionExit(Collision collision)
        {
            // Leaving Planet SOI
        }

        public void OnButtonClick()
        {
            Thrust();
            Debug.Log($" - THRUSTING! BWRAAAWWWRRAARPPP ");
                /*
            isOrbiting = false;
            isTransferring = true;
                */
        }

        void Rotate()
        {
            this.transform.Rotate(Vector3.up, orbitSpeed);
        }

        public void Thrust(bool retro = false)
        {
            if (retro == false)
            {
                Debug.Log($" - Thrusting proPS? ");
                playerRocketRB.AddRelativeForce(Vector3.forward * transferSpeed);
                proPS.gameObject.SetActive(true);
            }
            else
            {
                Debug.Log($" - Thrusting retroPS? ");
                playerRocketRB.AddRelativeForce(-Vector3.forward * transferSpeed);
                retroPS.gameObject.SetActive(true);
            }
        }

        public void DisableThrusters()
        {
            retroPS.gameObject.SetActive(false);
            proPS.gameObject.SetActive(false);
        }

        void Transfer()
        {
            playerRocketRB.velocity = (Vector3.forward * transferSpeed);
        }
    }
}
