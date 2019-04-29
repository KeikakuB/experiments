using UnityEngine;
using System.Collections;

public class LoadingText : MonoBehaviour {

	public float pulseTime;
	public int numberOfPulses;

	private float lastPulse;
	private string text = "Loading ";
	private int dots = 0;

	// Use this for initialization
	void Start () {
		Invoke("GoToGame", pulseTime * numberOfPulses);
		lastPulse = Time.time;
		guiText.text = text + new string ('*', dots + 1);
	}
	
	// Update is called once per frame
	void Update () {
		if(pulseTime < Time.time - lastPulse) {
			ChangeDots();
			lastPulse = Time.time;
		}
	}

	void ChangeDots() {
		dots += 1;
		dots %= 3;
		guiText.text = text + new string ('*', dots + 1);
	}

	void GoToGame() {
		UnityEngine.Application.LoadLevel("game");
	}
}
