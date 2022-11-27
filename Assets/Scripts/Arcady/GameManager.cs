using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    private static GameManager instance;
    public static GameManager Instance { get{ return instance; } private set{ instance = value; } }

    public GameObject losePanel;
    public GameObject winPanel;
    public GameObject gameButton;

    public int starFishesCollected = 0;
    public TextMeshProUGUI starFishText;
    
    public int currentHealth = 3;

    public GameObject heart1;
    public GameObject heart2;
    public GameObject heart3;

    public Animator playerAnimator;

    private void Awake() 
    { 
        // If there is an instance, and it's not me, delete myself.
        if (Instance != null && Instance != this) 
        { 
            Destroy(this); 
        } 
        else 
        { 
            Debug.Log($" - GameManager instance Hooked!");
            Instance = this; 
        } 
    }

    public void DisplayLoose()
    {
        if (losePanel != null)
        {
            losePanel.SetActive(true);
            gameButton.SetActive(false);
        }
    }
    
    public void DisplayWin()
    {
        if (winPanel != null)
        {
            winPanel.SetActive(true);
            gameButton.SetActive(false);
        }
    }

    public void IncreseScore()
    {
        starFishesCollected++;
        starFishText.text = $"{starFishesCollected}";
    }

    public void GetHit()
    {
        if (winPanel.activeSelf == true ||
            losePanel.activeSelf == true)
        {
            return;
        }

        currentHealth--;

        if (currentHealth == 3)
        {
            return;
        }
        
        if (currentHealth == 2)
        {
            playerAnimator.SetTrigger("hurt");

            heart3.SetActive(false);
            return;
        }
        
        if (currentHealth == 1)
        {
            playerAnimator.SetTrigger("hurt");

            heart2.SetActive(false);
            return;
        }
        
        if (currentHealth == 0)
        {
            playerAnimator.SetTrigger("death");

            heart1.SetActive(false);
            DisplayLoose();
            return;
        }
    }

    public void Restart()
    {
        SceneManager.LoadScene("ArcadyBulletVersion");
    }
}
