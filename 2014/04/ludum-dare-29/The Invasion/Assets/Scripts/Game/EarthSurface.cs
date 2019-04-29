using UnityEngine;
using System.Collections;

public class EarthSurface : MonoBehaviour {

	public bool hasPodSurfaced = false;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void OnCollisionEnter2D(Collision2D coll) {
		if( coll.gameObject.tag == "Pod" && !hasPodSurfaced ) {
			hasPodSurfaced = true;
			PodMovement pm = coll.gameObject.GetComponent<PodMovement>();
			if( pm != null ) {
				pm.OnHitEarthSurface();
			}
			Status st = GameObject.FindObjectOfType<Status>();
			if( st != null ) {
				st.HasBreachedSurface();
			}
		}
	}
}
