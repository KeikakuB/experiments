using UnityEngine;
using System.Collections;

public class Status : MonoBehaviour {

	public float timeToWaitForNextLaunchAfterFailure = 2.5f;
	public float timeToWaitForNextLaunchAfterSuccess = 5f;

	private bool hasBreachedSurface = false;
	private bool hasFailedToBreachSurface = false;
	private float timeBreached;
	private float timeFailedBreach;
	private string statusText;

	private Score score;

	private AudioSource[] sources;
	// Use this for initialization
	void Start () {
		sources = GetComponents<AudioSource>();
		score = GameObject.FindObjectOfType<Score>();
		GetComponent<GUIText>().text = "Guide the invasion pod to the surface!";
	}
	
	// Update is called once per frame
	void Update () {
		if( hasBreachedSurface ) {
			float timeLeft = timeToWaitForNextLaunchAfterSuccess - (Time.time - timeBreached);
			UpdateText(timeLeft);
		}

		if( hasFailedToBreachSurface ) {
			float timeLeft = timeToWaitForNextLaunchAfterFailure - (Time.time - timeFailedBreach);
			UpdateText(timeLeft);
		}
	}

	void UpdateText(float timeLeft) {
		if(timeLeft > 0 ) {
			GetComponent<GUIText>().text = statusText + timeLeft.ToString("F");
		} else {
			GetComponent<GUIText>().text = statusText + "0.00";
		}
	}

	public void HasBreachedSurface() {
		sources[0].Play();
		hasBreachedSurface = true;
		timeBreached = Time.time;
		statusText = "Success! Pod has breached the Surface! Next Pod Launch in : ";
		score.IncrementSuccessfulBreaches();
		Invoke("GoToNextLaunch", timeToWaitForNextLaunchAfterSuccess);
	}

	public void HasHitAnObstacle() {
		sources[1].Play();
		hasFailedToBreachSurface = true;
		timeFailedBreach = Time.time;
		statusText = "Failure! Pod   Next Pod Launch in : ";
		score.IncrementFailedBreaches();
		Invoke("GoToNextLaunch", timeToWaitForNextLaunchAfterFailure);
	}

	void GoToNextLaunch() {
		Application.LoadLevel(Application.loadedLevel);
	}
}
