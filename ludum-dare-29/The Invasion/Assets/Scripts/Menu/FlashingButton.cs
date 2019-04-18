using UnityEngine;
using System.Collections;

public class FlashingButton : MonoBehaviour {
	
	public float flashRate;

	private bool isClear = true;
	private SpriteRenderer sr;
	// Use this for initialization
	void Start () {
		sr = GetComponent<SpriteRenderer>();
		InvokeRepeating("ToggleColor", 0.0f, flashRate);
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void ToggleColor() {
		if(!isClear) {
			sr.color = Color.magenta;
		} else {
			sr.color = Color.red;
		}
		isClear = !isClear;
	}
}
