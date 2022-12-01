using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class Player_Movement_Boost : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
{
    public bool buttonPressed;
    
    public Canvas gameCanvas;

    public Transform center;
    public Vector2 startPosition;
    public float maxLength;
    public Vector2 currentPosition;
    
    public Vector2 boostVector;

    public Rigidbody2D playerRB;
    public Animator playerAnimator;

    public float boostMultiplyer = 1.0f;
    public float slowdownScalar = 0.2f;
    private float oldGravity;

    public GameObject arrowObject;
    public ParticleSystem bubblesPS;

    public Image arrowTipImage;
    public Image arrowEndImage;
    
    public Image joyBack;
    public Image joyKnob;

    private void FixedUpdate()
    {
        if (buttonPressed == true)
        {
            currentPosition = Input.mousePosition;
            currentPosition = startPosition + Vector2.ClampMagnitude(currentPosition - startPosition, maxLength);

            Vector3 startLine = Camera.main.ScreenToWorldPoint(startPosition);
            startLine.z = 0.0f;
            Vector3 endLine = Camera.main.ScreenToWorldPoint(currentPosition);
            endLine.z = 0.0f;
            
            boostVector = (startPosition - currentPosition).normalized;
            boostMultiplyer = (startPosition - currentPosition).magnitude;
            // Mathf.Clamp(boostMultiplyer, 0.0f, 1.0f);
            boostMultiplyer = Mathf.Abs(boostMultiplyer / maxLength);
            
            Debug.DrawLine(startPosition, boostVector*boostMultiplyer, Color.green);
            Debug.DrawLine(center.position, center.position+((Vector3)boostVector*5.0f), Color.red);

            if (boostVector.magnitude > 0.01f)
            {
                float lookaheadLength = 5.0f;
                playerRB.transform.right = ((Vector3)boostVector*lookaheadLength);

                arrowTipImage.transform.localScale = new Vector3(
                    arrowTipImage.transform.localScale.x, 
                    Mathf.Clamp(boostMultiplyer, 0.5f, 1.0f),
                    arrowTipImage.transform.localScale.z);
                
                arrowEndImage.transform.localScale = new Vector3(
                    arrowEndImage.transform.localScale.x, 
                    Mathf.Clamp(boostMultiplyer, 0.5f, 1.0f),
                    arrowEndImage.transform.localScale.z);
            }

            playerAnimator.SetTrigger("aiming");
            
            //Debug.Log($" - boostMultiplyer {boostMultiplyer} | boostVector {boostVector} ");

            return;
        }

        if (boostVector != Vector2.zero)
        {
            playerRB.velocity = Vector2.zero;
            playerRB.AddForce( boostVector * 880.0f * boostMultiplyer );
            boostVector = Vector3.zero;
            boostMultiplyer = 1.0f;
            
            arrowObject.SetActive(false);

            //Debug.Log($" - SWIM!");
            bubblesPS.Play();
            playerAnimator.SetTrigger("shoot");
            playerAnimator.SetBool("isBoosting", true);
            return;
        }
        
        if (playerRB.velocity.magnitude > 10.0f)
        {
            //Debug.Log($" - BOOST FRAMES!");
            return;
        }
        else if (playerAnimator.GetBool("isBoosting") == true)
        {
            //Debug.Log($" - ok we good.");
            playerAnimator.SetBool("isBoosting", false);
        }

    }
    
    public void OnPointerDown(PointerEventData eventData)
    {
        playerRB.velocity *= slowdownScalar;

        oldGravity = playerRB.gravityScale;
        playerRB.gravityScale *=  slowdownScalar;

        Vector3 mousePosition = Input.mousePosition;
        startPosition = mousePosition;

        buttonPressed = true;
    }
 
    public void OnPointerUp(PointerEventData eventData)
    {
        playerRB.gravityScale = oldGravity;

        buttonPressed = false;
        joyBack.gameObject.SetActive(false);
    }
}
