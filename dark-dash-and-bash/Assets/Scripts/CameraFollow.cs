using UnityEngine;
using System.Collections;

public class CameraFollow : MonoBehaviour {

    public GameObject ObjectToFollow;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        if (ObjectToFollow != null)
        {
            float x = ObjectToFollow.transform.position.x;
            float z = ObjectToFollow.transform.position.z;
            transform.position = new Vector3(x, transform.position.y, z);
        }
	}
}
