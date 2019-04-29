using UnityEngine;
using System.Collections;

public class OrbOfLight : MonoBehaviour {
    public float MinReleaseForce;
    public float MaxReleaseForce;
    public AudioSource PickupSound;
    public AudioSource DropSound;
    public bool IsCarriedByExplorer {get; private set;}
    private bool wasReleased = false;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    void FixedUpdate()
    {
        if (wasReleased)
        {
            Vector2 randForce = Random.insideUnitCircle;
            transform.position = new Vector3(
                transform.position.x + 1.5f * randForce.x,
                transform.position.y,
                transform.position.z + 1.5f * randForce.y);
            randForce *= Random.Range(MinReleaseForce, MaxReleaseForce);
            Vector3 forceIn3d = new Vector3(randForce.x, 0f, randForce.y);
            GetComponent<Rigidbody>().AddForce(forceIn3d);
            wasReleased = false;
        }
    }

    void OnCollisionEnter(Collision collision)
    {
        if (!IsCarriedByExplorer && collision.collider.tag == "Explorer")
        {
            ExplorerController ec = collision.collider.GetComponent<ExplorerController>();
            if (!ec.IsStunned && !ec.CannotPickupOrb)
            {
                PickupSound.Play();
                GetComponent<Rigidbody>().isKinematic = true;
                ec.OnTouchOrbOfLight(this);
                IsCarriedByExplorer = true;
            }
        }
    }

    public void OnRelease()
    {
        DropSound.Play();
        transform.parent = null;
        GetComponent<Rigidbody>().isKinematic = false;
        wasReleased = true;
        IsCarriedByExplorer = false;
    }
}
