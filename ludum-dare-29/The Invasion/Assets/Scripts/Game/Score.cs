using UnityEngine;
using System.Collections;

public class Score : MonoBehaviour {
	private string scoreSuccessfulBreaches = "SCORE_SUCCESS";
	private string scoreFailedBreaches = "SCORE_FAILURE";

	private int[] rankSuccessesNeeded = {1, 3, 7, 15, 30, int.MaxValue};
	private string[] rankNames = {"Intern", "Rookie", "New Employee", "Employee", "Respected Employee", "VIP"};
	// Use this for initialization
	void Start () {
		SetKeysIfNotSet();
		UpdateText();
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	public void IncrementSuccessfulBreaches() {
		SetKeysIfNotSet();
		int s = PlayerPrefs.GetInt(scoreSuccessfulBreaches);
		PlayerPrefs.SetInt(scoreSuccessfulBreaches, s + 1);
		PlayerPrefs.Save();
		UpdateText();
	}

	public void IncrementFailedBreaches() {
		SetKeysIfNotSet();
		int s = PlayerPrefs.GetInt(scoreFailedBreaches);
		PlayerPrefs.SetInt(scoreFailedBreaches, s + 1);
		PlayerPrefs.Save();
		UpdateText();
	}

	void SetKeysIfNotSet() {
		if(!PlayerPrefs.HasKey(scoreSuccessfulBreaches)) {
			PlayerPrefs.SetInt(scoreSuccessfulBreaches, 0);
		}
		
		if(!PlayerPrefs.HasKey(scoreFailedBreaches)) {
			PlayerPrefs.SetInt(scoreFailedBreaches, 0);
		}
		PlayerPrefs.Save();
	}

	void UpdateText() {
		guiText.text = "Rank: " + rankNames[GetRankIndex()] + "\n" +
			 getNextRankText()+ "\n" +
			"Successful Breaches: " + PlayerPrefs.GetInt(scoreSuccessfulBreaches) + "\n" +
			"Failed Breaches: " + PlayerPrefs.GetInt(scoreFailedBreaches);
	}

	int GetRankIndex() {
		int successes = PlayerPrefs.GetInt(scoreSuccessfulBreaches);
		for(int i = 1; i < rankSuccessesNeeded.Length; i++ ) {
			int now = rankSuccessesNeeded[i-1];
			int next = rankSuccessesNeeded[i];
			if(successes >= now && successes < next) {
				return i;
			}
		}
		return 0;
	}

	string getNextRankText() {
		int current = PlayerPrefs.GetInt(scoreSuccessfulBreaches);
		int rankIndex = GetRankIndex();
		if(rankIndex == rankSuccessesNeeded.Length - 1) {
			return "Achieved maximum rank!";
		} else {
			return "Succeed " + (rankSuccessesNeeded[rankIndex] - current) + " more times for next rank";
		}

	}
}
