using UnityEngine;
using UnityEngine.EventSystems;

public class Player_Movement_Boost : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
{
    public bool buttonPressed;
    
    public Transform center;
    public Vector2 startPosition;
    public float maxLength;
    public Vector2 currentPosition;
    
    public Vector2 boostVector;

    public Rigidbody2D playerRB;

    public float boostMultiplyer = 1.0f;
    public float slowdownScalar = 0.2f;
    private float oldGravity;

    private void FixedUpdate()
    {
        if (buttonPressed == true)
        {
            //Vector3 mousePosition = Input.mousePosition;
            currentPosition = Input.mousePosition;
            //currentPosition = Camera.main.ScreenToWorldPoint(mousePosition);
            //currentPosition.z = playerRB.transform.position.z;
            currentPosition = startPosition + Vector2.ClampMagnitude(currentPosition - startPosition, maxLength);

            /* Around Squid
            currentPosition = Camera.main.ScreenToWorldPoint(mousePosition);
            currentPosition.z = playerRB.transform.position.z;
            currentPosition = center.position + Vector3.ClampMagnitude(currentPosition - center.position, maxLength);
            */
            
            Vector3 startLine = Camera.main.ScreenToWorldPoint(startPosition);
            startLine.z = 1.0f;

            Vector3 endLine = Camera.main.ScreenToWorldPoint(currentPosition);
            endLine.z = 1.0f;

            Debug.DrawLine(startLine, endLine);

            boostVector = (startPosition - currentPosition).normalized;
            boostMultiplyer = (startPosition - currentPosition).magnitude;
            boostMultiplyer = Mathf.Clamp(boostMultiplyer, 0.0f, 1.0f);
            
            Debug.DrawLine(center.position, center.position+((Vector3)boostVector*5.0f));

            if (boostVector.magnitude > 0.01f)
            {
                playerRB.transform.right = ((Vector3)boostVector*5.0f);
            }

            Debug.Log($" - boostMultiplyer {boostMultiplyer} | boostVector {boostVector} ");

            return;
        }

        if (boostVector != Vector2.zero)
        {
            playerRB.velocity = Vector2.zero;
            playerRB.AddForce( boostVector * 880.0f * boostMultiplyer );
            boostVector = Vector3.zero;
            boostMultiplyer = 1.0f;
            Debug.Log($" - SWIM!");
            return;
        }
        
    }
    
    public void OnPointerDown(PointerEventData eventData)
    {
        playerRB.velocity *= slowdownScalar;

        oldGravity = playerRB.gravityScale;
        playerRB.gravityScale *=  slowdownScalar;

        Vector3 mousePosition = Input.mousePosition;
        startPosition = mousePosition;
        //startPosition = Camera.main.ScreenToWorldPoint(mousePosition);
            
        buttonPressed = true;
    }
 
    public void OnPointerUp(PointerEventData eventData)
    {
        playerRB.gravityScale = oldGravity;

        buttonPressed = false;
    }
}
