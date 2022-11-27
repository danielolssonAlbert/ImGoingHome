using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    private static GameManager instance;
    public static GameManager Instance { get{ return instance; } private set{ instance = value; } }

    public GameObject losePanel;
    public GameObject gameButton;

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

    public void Restart()
    {
        SceneManager.LoadScene("ArcadyBulletVersion");
    }
}
