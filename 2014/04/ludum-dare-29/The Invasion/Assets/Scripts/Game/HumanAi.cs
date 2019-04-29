using UnityEngine;
using System.Collections;

public class HumanAi : MonoBehaviour {

	[HideInInspector]
	public GameObject target;

	public float minRunForce;
	public float maxRunForce;

	private float actualRunForce;

	// Use this for initialization
	void Start () {
		actualRunForce = Random.Range(minRunForce, maxRunForce);
	}
	
	// Update is called once per frame
	void Update () {
	}

	void FixedUpdate() {
		if(target != null) {
			Vector2 diff = target.transform.position - transform.position;
			float dir = diff.x > 0 ? -1 : 1;
			rigidbody2D.velocity = new Vector2(dir * actualRunForce, rigidbody2D.velocity.y);
		}
	}
}
