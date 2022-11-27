using UnityEngine;
using UnityEngine.EventSystems;
using IGH.Movement;

public class ButtonHeld : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
{
    public bool buttonPressed;
    public bool buttonRetro = false;
    public PlayerMovement playerMovement;

    private void FixedUpdate()
    {
        if (buttonPressed == true)
        {
            playerMovement.Thrust(buttonRetro);
        }
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        buttonPressed = true;
    }
 
    public void OnPointerUp(PointerEventData eventData)
    {
        playerMovement.DisableThrusters();
        buttonPressed = false;
    }
}