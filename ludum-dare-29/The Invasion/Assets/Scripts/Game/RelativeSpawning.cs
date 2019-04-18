using UnityEngine;
using System.Collections;

public class RelativeSpawning : MonoBehaviour {

	public GameObject objectToSpawn;
	public float verticalOffsetFromSelf = 10f;
	public float minHoriOffset = -5f;
	public float maxHoriOffset = 5f;
	public float minSpawnTime = 1f;
	public float maxSpawnTime = 3f;

	public float startSpawningAfter = 0.0f;
	public float numberOfSecondsToSpawnFor = 10f;

	private bool isSpawning = false;
	private float startTime;
	private float startedSpawningTime;
	private float nextSpawnTime;
	private float lastTimeSpawned;



	// Use this for initialization
	void Start () {
		startTime = Time.time;
		ResetSpawnTime();
	}
	
	// Update is called once per frame
	void Update () {
		if(isSpawning) {
			if( lastTimeSpawned < Time.time - nextSpawnTime ) {
				SpawnObject();
				ResetSpawnTime();
			}
			if(numberOfSecondsToSpawnFor < Time.time - startedSpawningTime ) {
				Destroy(this);
			}
		} else {
			if(startSpawningAfter < Time.time - startTime) {
				ResetSpawnTime();
				startedSpawningTime = Time.time;
				isSpawning = true;
			}
		}
	}

	void ResetSpawnTime() {
		lastTimeSpawned = Time.time;
		nextSpawnTime = Random.Range(minSpawnTime, maxSpawnTime);
	}

	void SpawnObject() {
		float x = Random.Range(minHoriOffset, maxHoriOffset);
		float y = verticalOffsetFromSelf;
		Vector3 offsetFromSelf = new Vector3(x, y);
		GameObject cloned = (GameObject) Instantiate(objectToSpawn, transform.position + offsetFromSelf, new Quaternion());
		Obstacle obs = cloned.GetComponent<Obstacle>();
		if( obs != null ) {
			obs.activeObject = this.gameObject;
		}
	}
}
