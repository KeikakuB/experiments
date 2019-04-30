using UnityEngine;
using System.Collections;

public class InvaderControls : MonoBehaviour {

	public float horizontalForce;

	// Use this for initialization
	void Start () {
		GameObject[] objs = GameObject.FindGameObjectsWithTag("Human");
		foreach(GameObject o in objs) {
			HumanAi ai = o.GetComponent<HumanAi>();
			if( ai != null ) {
				ai.target = this.gameObject;
			}
		}
	}
	
	// Update is called once per frame
	void Update () {

	}
	void FixedUpdate() {
		float h = Input.GetAxis("Horizontal");

		GetComponent<Rigidbody2D>().AddForce(new Vector2(h * horizontalForce, 0));
	}
}
