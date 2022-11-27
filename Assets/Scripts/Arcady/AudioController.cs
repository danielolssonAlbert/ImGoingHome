using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioController : MonoBehaviour
{
    private static AudioController instance;
    public static AudioController Instance { get{ return instance; } private set{ instance = value; } }

    public List<AudioClip> bumpAudio;
    public List<AudioClip> deathAudio;
    public List<AudioClip> hitAudio;
    public List<AudioClip> eatAudio;
    
    private AudioSource audioContainer;

    private void Awake()
    {
        // If there is an instance, and it's not me, delete myself.
        if (Instance != null && Instance != this) 
        { 
            Destroy(this); 
        } 
        else 
        { 
            Debug.Log($" - AudioController instance Hooked!");
            Instance = this; 
        } 

        audioContainer = GetComponent<AudioSource>();
    }

    public void PlayOnHit()
    {
        int possibleAudio = hitAudio.Count;
        int playIndex = Random.Range(0,possibleAudio);
        audioContainer.PlayOneShot(hitAudio[playIndex]);
    }
    
    public void PlayOnDeath()
    {
        int possibleAudio = deathAudio.Count;
        int playIndex = Random.Range(0,possibleAudio);
        audioContainer.PlayOneShot(deathAudio[playIndex]);
    }
    
    public void PlayOnEat()
    {
        int possibleAudio = eatAudio.Count;
        int playIndex = Random.Range(0,possibleAudio);
        audioContainer.PlayOneShot(eatAudio[playIndex]);
    }
    public void PlayOnBump()
    {
        int possibleAudio = bumpAudio.Count;
        int playIndex = Random.Range(0,possibleAudio);
        audioContainer.PlayOneShot(bumpAudio[playIndex]);
    }
}
