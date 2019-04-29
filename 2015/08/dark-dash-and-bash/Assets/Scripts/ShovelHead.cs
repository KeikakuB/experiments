using UnityEngine;
using System.Collections;

public class ShovelHead : MonoBehaviour {
    public float Lifetime;
    public GameObject Parent;
    private bool hasHitSomeone = false;
	// Use this for initialization
	void Start () {
        Destroy(this.gameObject, Lifetime);
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    public void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.tag == "Explorer" 
            && collision.collider.gameObject != Parent
            && !hasHitSomeone)
        {
            hasHitSomeone = true;
            ExplorerController ec = collision.collider.GetComponent<ExplorerController>();
            ec.OnHit();
            Destroy(this.gameObject);
        }
    }
}
