using UnityEngine;
using System.Collections;

public class CameraFollow : MonoBehaviour {

	public GameObject target;

	public Vector2 followOffset;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		if( target != null ) {
			transform.position = new Vector3(target.transform.position.x + followOffset.x, target.transform.position.y + followOffset.y, transform.position.z);
		}
	}
}
