using UnityEngine;
using System.Collections;

public class Obstacle : MonoBehaviour {

	[HideInInspector]
	public GameObject activeObject;
	
	public float deleteDistance;
	public float timeBetweenDeleteChecks;

	// Use this for initialization
	void Start () {
		InvokeRepeating("CheckForDelete", timeBetweenDeleteChecks, timeBetweenDeleteChecks);
	}
	
	// Update is called once per frame
	void Update () {
	}

	void CheckForDelete() {
		if(activeObject != null && Vector2.Distance(activeObject.transform.position, transform.position) > deleteDistance) {
			Destroy(gameObject);
		}
	}

	void OnTriggerEnter2D(Collider2D coll) {
		if( coll.gameObject.tag == "Pod" ) {
			Status st = GameObject.FindObjectOfType<Status>();
			if( st != null ) {
				st.HasHitAnObstacle();
			}
			PodMovement pm = coll.gameObject.GetComponent<PodMovement>();
			if( pm != null ) {
				pm.OnHitObstacle();
			}
		}
	}
}
