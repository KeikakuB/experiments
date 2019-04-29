using UnityEngine;
using System.Collections;

public class MainMenu : MonoBehaviour {

	private float fuzz = 0.1f;

	private float timeBetweenPlayerInput = 2.0f;
	private float lastTimeForPlayerInput;

	// Use this for initialization
	void Start () {
		lastTimeForPlayerInput = Time.time;
	}
	
	// Update is called once per frame
	void Update () {
		if(timeBetweenPlayerInput < Time.time - lastTimeForPlayerInput) {
			//react to player input
			float h = Input.GetAxis( "Horizontal" );
			float v = Input.GetAxis( "Vertical" );
			if( Mathf.Abs( h - fuzz ) > fuzz ||
			   Mathf.Abs( v - fuzz ) > fuzz ) {
				Application.LoadLevel( "gameScene" );
			}
		}
	}
}
