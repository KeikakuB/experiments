using UnityEngine;
using System.Collections;

public class ExitLadder : MonoBehaviour {
    public AudioSource WinSound;
    private bool isGameOver = false;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    public void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.tag == "Explorer" && !isGameOver)
        {
            ExplorerController ec = collision.collider.GetComponent<ExplorerController>();
            if (ec.IsCarryingOrbOfLight)
            {
                WinSound.Play();
                //TODO: add game over message
                Time.timeScale = 0.0f;
                isGameOver = true;
            }
        }
    }
}
