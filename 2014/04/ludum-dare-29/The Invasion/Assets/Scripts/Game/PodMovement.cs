using UnityEngine;
using System.Collections;

public class PodMovement : MonoBehaviour {

	public float speed;
	public float turnRate;
	public float maxTurn;

	public Rigidbody2D invader;

	
	private bool wantsToTurnLeft;
	private bool wantsToTurnRight;

	private bool hasHitEarthsSurface = false;
	private bool isDisabled = false;

	private AudioSource[] sources;

	// Use this for initialization
	void Start () {
		sources = GetComponents<AudioSource>();
		wantsToTurnLeft = false;
		wantsToTurnRight = false;
	}
	
	// Update is called once per frame
	void Update () {
		float h = Input.GetAxis("Horizontal");
		if(Mathf.Abs(h) > 0.1 && !hasHitEarthsSurface && !isDisabled) {
			if( h < 0 && transform.up.x > -maxTurn) {
				if(!sources[1].isPlaying) {
					sources[1].Play();
				}
				wantsToTurnLeft = true;
			} else if( h > 0 && transform.up.x < maxTurn) {
				if(!sources[1].isPlaying) {
					sources[1].Play();
				}
				wantsToTurnRight = true;
			}
		}
	}

	void FixedUpdate() {
		if( !hasHitEarthsSurface && !isDisabled) {
			GetComponent<Rigidbody2D>().velocity = transform.up * speed;

			if(wantsToTurnLeft && !wantsToTurnRight) {
				transform.RotateAround(transform.position, new Vector3(0, 0, 1), turnRate);
			}

			if(wantsToTurnRight && !wantsToTurnLeft) {
				transform.RotateAround(transform.position, new Vector3(0, 0, 1), -turnRate);
			}
			wantsToTurnLeft = false;
			wantsToTurnRight = false;
		}
	}

	public void OnHitEarthSurface() {
		sources[2].Play();
		sources[0].Stop();
		hasHitEarthsSurface = true;
		Vector3 newPos = transform.position;
		newPos.y += 2.0f;
		transform.position = newPos;
		Vector3 newUp = transform.up;
		newUp.x = 0.0f;
		transform.up = newUp;
		GetComponent<Rigidbody2D>().velocity = new Vector2();
		GetComponent<Rigidbody2D>().gravityScale = 1.0f;
		GetComponent<Rigidbody2D>().AddForce(new Vector2(0f, 200f));
		Invoke("EjectInvader", 1.0f);
	}

	public void OnHitObstacle() {
		sources[3].Play();
		sources[0].Stop();
		isDisabled = true;
		GetComponent<Rigidbody2D>().velocity = new Vector2();
	}

	void EjectInvader() {
		Rigidbody2D inv = (Rigidbody2D) Instantiate(invader, transform.position + new Vector3(0.5f, 0f, 0f), new Quaternion());
		inv.AddForce(new Vector2(10, 15));
		GameObject.FindObjectOfType<CameraFollow>().target = inv.gameObject;
	}


}
