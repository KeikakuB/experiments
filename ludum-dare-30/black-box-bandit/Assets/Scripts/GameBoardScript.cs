using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class GameBoardScript : MonoBehaviour {

	public class IntVector2 {
		public readonly int x;
		public readonly int y;

		public IntVector2(int x, int y) {
			this.x = x;
			this.y = y;
		}

		public bool Equals(IntVector2 other)
		{
			return Equals(other, this);
		}
		
		public override bool Equals(object obj)
		{
			if (obj == null || GetType() != obj.GetType())
			{
				return false;
			}
			var objectToCompareWith = (IntVector2) obj;
			return objectToCompareWith.x == x && objectToCompareWith.y == y;
		}

		public static bool operator ==(IntVector2 a, IntVector2 b)
		{
			// If both are null, or both are same instance, return true.
			if (System.Object.ReferenceEquals(a, b))
			{
				return true;
			}
			
			// If one is null, but not both, return false.
			if (((object)a == null) || ((object)b == null))
			{
				return false;
			}
			
			// Return true if the fields match:
			return a.x == b.x && a.y == b.y;
		}
		
		public static bool operator !=(IntVector2 a, IntVector2 b)
		{
			return !(a == b);
		}
	}

	public enum Direction {
		Up,
		Down,
		Left,
		Right
	}

	public GameObject blackBoxBanditTemplate;
	public GameObject goldenKeyTemplate;
	public GameObject evenDroneTemplate;
	public GameObject floorTileTemplate;
	public GameObject wallTileTemplate;
	public GameObject exitTileTemplate;
	public GameObject boardHiderTemplate;

	/// <summary>
	/// The minimum manhattan distance between bandit and drone spawns.
	/// </summary>
	public int minimumManhattanDistanceBetweenBanditAndDroneSpawns;

	/// <summary>
	/// The number of rows for each black box.
	/// </summary>
	public int numberOfRows;
	/// <summary>
	/// The number of columns for each black box.
	/// </summary>
	public int numberOfColumns;
	/// <summary>
	/// The number of drones.
	/// 
	/// NB: Changes over time.
	/// </summary>
	public int numberOfDrones;

	/// <summary>
	/// The number of drones to add to the current total after a win.
	/// </summary>
	public int numberOfDronesToIncrementBy;

	/// <summary>
	/// The number of drones to remove from the current total after a loss.
	/// </summary>
	public int numberOfDronesToDecrementBy;

	/// <summary>
	/// The time delay in seconds between each drone's move.
	/// </summary>
	public float delayTimeBetweenDroneMoves;

	public float timeBetweenPlayerInput;
	private float lastTimeForPlayerInput;

	private GameObject [,] board; //TODO: should each grid location be able to contain many GameObjects??? (List<GameObject>[,])

	private GameObject blackBoxBandit;
	private GameObject goldenKey;
	private IntVector2 goldenKeyLocation;
	private GameObject exit;
	private IntVector2 exitLocation;
	private List<GameObject> drones;
	private List<GameObject> walls;
	private GameObject boardHider;

	private bool doesBanditHaveKey;
	private bool ignorePlayerInput;

	private float fuzz = 0.1f;

	private AudioSource sourcePlayerMove;
	private AudioSource sourceDroneMove;
	private AudioSource sourceKeyGet;
	private AudioSource sourcePlayerWin;
	private AudioSource sourcePlayerLose;
	private AudioSource sourceThemeTubeRiding;


	// Use this for initialization
	void Start () {
		//initial setup
		var sources = GetComponents<AudioSource>();
		sourcePlayerMove = sources[ 0 ];
		sourceDroneMove = sources[ 1 ];
		sourceKeyGet = sources[ 2 ];
		sourcePlayerWin = sources[ 3 ];
		sourcePlayerLose = sources[ 4 ];
		sourceThemeTubeRiding = sources[ 5 ];

		ignorePlayerInput = false;
		lastTimeForPlayerInput = Time.time;
		UpdateText();
		ResetBlackBox();
	}
	
	// Update is called once per frame
	void Update () {
		if( Input.GetKeyDown(KeyCode.Escape) ) {
			Application.Quit();
		}
		if(!ignorePlayerInput && timeBetweenPlayerInput < Time.time - lastTimeForPlayerInput) {
			//react to player input
			float h = Input.GetAxis( "Horizontal" );
			float v = Input.GetAxis( "Vertical" );
			if( Mathf.Abs( h - fuzz ) > fuzz ||
			    Mathf.Abs( v - fuzz ) > fuzz ) {
				TryToTakeTurn( h , v );
			}
		}
	}

	void UpdateText() {
		guiText.text = "\"Bandit, you're in Black Box #" + UnityEngine.Random.Range(0, 9999) + " with a Difficulty Level of " + numberOfDrones + ", be careful out there.\"" ;
	}

	/// <summary>
	/// Computes the manhattan distance between the two given points.
	/// </summary>
	/// <returns>The manhattan distance.</returns>
	/// <param name="p1">first point</param>
	/// <param name="p2">second point</param>
	int ComputeManhattanDistance(IntVector2 p1, IntVector2 p2) {
		return Mathf.Abs( p1.x - p2.x ) + Mathf.Abs( p1.y - p2.y );
	}

	/// <summary>
	/// Tries to take turn.
	/// </summary>
	/// <returns>
	/// <c>true</c>, if given input represented a valid move considering the current state of the board, 
	/// <c>false</c> otherwise.
	/// </returns>
	/// <param name="h">The horizontal input</param>
	/// <param name="v">The vertical input</param>
	void TryToTakeTurn(float h, float v) {
		bool isActionValid = false;
		bool isRoundOver = false;
		//find the current position of the BBB
		var banditPosition = FindPiecePosition( blackBoxBandit );
		if( banditPosition == null ) {
			return;
		}
		IntVector2 moveToPosition = null;
		//compute the point the player wishes to move to
		if( Mathf.Abs( h - fuzz ) > fuzz ) {
			//try to move left
			if( h < 0 ) {
				moveToPosition = GetPositionInDirection( banditPosition , Direction.Left );
			} 
			//try to move right
			else {
				moveToPosition = GetPositionInDirection( banditPosition , Direction.Right );
			}
		} else if ( Mathf.Abs( v - fuzz ) > fuzz ) {
			//try to move down
			if( v < 0 ) {
				moveToPosition = GetPositionInDirection( banditPosition , Direction.Down );
			} 
			//try to move up
			else {
				moveToPosition = GetPositionInDirection( banditPosition , Direction.Up );
			}
		}
		//check if move is valid
		if( moveToPosition != null && IsInBounds(moveToPosition) ) {
			//find the piece on the position the player is trying to move to
			var pieceOnMovePosition = GetPieceByPosition( moveToPosition );
			//if the player is not trying to move onto a wall
			if( !walls.Contains( pieceOnMovePosition ) ) {
				isActionValid = true;
				MovePiece( banditPosition, moveToPosition );
				//if player moved onto a drone
				if( drones.Contains( pieceOnMovePosition ) ) {
					//remove the drone from the black box
					sourcePlayerMove.Play();
					drones.Remove( pieceOnMovePosition );
					Destroy( pieceOnMovePosition );
				}
				//if player reached the key
				if ( !doesBanditHaveKey && goldenKeyLocation == moveToPosition ) {
					//give the key to the player
					sourceKeyGet.Play();
					doesBanditHaveKey = true;
				} 
				//if the bandit has the key and has reached the exit
				if ( doesBanditHaveKey && exitLocation == moveToPosition ) {
					//player has beat the current black box
					isRoundOver = true;
					OnBlackBoxRaidSuccess();
				}
			}
		}
		if( isActionValid ) {
			//update the time the player input a move
			lastTimeForPlayerInput = Time.time;
			if( !isRoundOver ) {
				//if there is at least one drone
				if( drones.Count > 0 ) {
					//disable player input
					ignorePlayerInput = true;
					int i = 1;
					//sort the drones by their x and y position to allow the player to determine the drones move/act ordering
					drones = drones.OrderBy( d => d.transform.position.x ).ThenByDescending( d => d.transform.position.y ).ToList();
					//run the drones AI, staggered in time using coroutines
					foreach(var d in drones) {
						//if d is the last drone then it should enable player input
						bool shouldEnablePlayerInput = i == drones.Count;
						StartCoroutine( DroneAct(i * delayTimeBetweenDroneMoves, d, shouldEnablePlayerInput ));
						i++;
					}
				}
			}
		}
	}

	IEnumerator DroneAct(float delay, GameObject d, bool isLastDrone) {
		yield return new WaitForSeconds(delay);
		sourceDroneMove.pitch = UnityEngine.Random.Range(0.3f, 1.2f);
		sourceDroneMove.Play();
		var from = FindPiecePosition( d );
		IntVector2 to;
		Direction[] directions = (Direction[]) Enum.GetValues( typeof(Direction) );
		List<IntVector2> possibleTos = directions.Select( dir => GetPositionInDirection(from, dir) ).Where( 
		                                                                                                   p => 
		                                                                                                   {
			if( IsInBounds( p ) ) {
				var pieceOnPosition = GetPieceByPosition( p ); 
				return !walls.Contains( pieceOnPosition ) &&
					!drones.Contains( pieceOnPosition );
			} else {
				return false;
			}
		}
		).ToList();
		if( possibleTos.Any( p => GetPieceByPosition( p ) == blackBoxBandit ) ) {
			to = possibleTos.Where( p => GetPieceByPosition( p ) == blackBoxBandit ).ToList()[0];
			MovePiece(from, to);
			StopAllCoroutines();
			OnBlackBoxRaidFailure();
		} else {
			if( possibleTos.Count > 0 ) {
				ShuffleList( possibleTos );
				to = possibleTos[0];
				MovePiece(from, to);
			}
		}
		if( isLastDrone ) {
			ignorePlayerInput = false;
			UpdateDroneColors();
		}
	}

	void UpdateDroneColors() {
		var banditPosition = FindPiecePosition( blackBoxBandit );
		if( banditPosition == null ) {
			return;
		}
		foreach(var r in drones) {
			var sr = r.GetComponent<SpriteRenderer>();
			var pos = FindPiecePosition( r );
			if( pos == null ) {
				continue;
			}
			if( ComputeManhattanDistance(pos, banditPosition ) % 2 == 0 ) {
				sr.color = Color.red;
			} else {
				sr.color = Color.blue;
			}
		}
	}

	/// <summary>
	/// Raises the black box raid success event.
	/// </summary>
	void OnBlackBoxRaidSuccess() {
		sourceThemeTubeRiding.Play();
		ignorePlayerInput = true;
		guiText.text = "\"Congratulations Bandit, you're now travelling to the next Black Box...\"";
		float waitTime = 0.25f;
		boardHider = (GameObject) Instantiate( boardHiderTemplate );
		MovePieceVisually( boardHider, new IntVector2( numberOfRows / 2, numberOfColumns / 2 ));
		IntVector2 current = FindPiecePosition( blackBoxBandit );
		for(int i = 1; i < 17; i++) {
			if( i == 11 ) {
				current = new IntVector2(-7, 0 );
			}
			current = new IntVector2( current.x + 1 , current.y );
			StartCoroutine( MovePieceVisuallyDelayed(i * waitTime, blackBoxBandit, current ) ); 
		}
		Invoke( "EndBlackBoxRaidSuccess" , 17 * waitTime );
	}

	/// <summary>
	/// Ends the black box raid success event.
	/// </summary>
	void EndBlackBoxRaidSuccess() {
		sourceThemeTubeRiding.Stop();
		Destroy( boardHider );
		ignorePlayerInput = false;
		numberOfDrones += numberOfDronesToIncrementBy;
		UpdateText();
		ResetBlackBox();
	}

	/// <summary>
	/// Raises the black box raid failure event.
	/// </summary>
	void OnBlackBoxRaidFailure() {
		sourcePlayerLose.Play();
		ignorePlayerInput = true;
		guiText.text = "\"You've been demuffinated, Bandit, I'm sending you back to an easier Black Box.\"";
		Invoke( "EndBlackBoxRaidFailure" , 4f);
	}

	/// <summary>
	/// Ends the black box raid failure event.
	/// </summary>
	void EndBlackBoxRaidFailure() {
		ignorePlayerInput = false;
		if( numberOfDrones - numberOfDronesToDecrementBy > 1) {
			numberOfDrones -= numberOfDronesToDecrementBy;
		}
		UpdateText();
		ResetBlackBox();
	}

	IEnumerator MovePieceVisuallyDelayed(float delay, GameObject piece, IntVector2 to)
	{
		yield return new WaitForSeconds( delay );
		MovePieceVisually( piece, to );
	}

	void MovePieceVisually(GameObject piece, IntVector2 to)
	{		
		Vector2 newVisualPosition = FromGridPositionToScreenPosition(to.x , to.y );
		piece.transform.position = new Vector3(newVisualPosition.x, newVisualPosition.y);
		
		if( piece == blackBoxBandit && doesBanditHaveKey ) {
			goldenKey.transform.position =  new Vector3(newVisualPosition.x, newVisualPosition.y); 
		}
	}
	
	void MovePiece(IntVector2 from, IntVector2 to)
	{
		GameObject piece = board[ from.x , from.y ];
		board[ to.x , to.y ] = piece;
		board[ from.x , from.y ] = null;

		MovePieceVisually( piece, to);
	}

	/// <summary>
	/// Determines whether the given v is in bounds of the board.
	/// </summary>
	/// <returns><c>true</c> if the given v is in bounds of the board; otherwise, <c>false</c>.</returns>
	/// <param name="v">the grid position to check</param>
	bool IsInBounds(IntVector2 v) {
		return 0 <= v.x && v.x < numberOfRows && 0 <= v.y && v.y < numberOfColumns;   
	}

	/// <summary>
	/// Gets the position next to the given position in the given direction.
	/// </summary>
	/// <returns>The desired position</returns>
	/// <param name="pos">the origin position</param>
	/// <param name="dir">the direction</param>
	IntVector2 GetPositionInDirection(IntVector2 pos, Direction dir) {
		switch( dir ) {
		case Direction.Up:
			return new IntVector2( pos.x , pos.y + 1 );
		case Direction.Down:
			return new IntVector2( pos.x , pos.y - 1 );
		case Direction.Left:
			return new IntVector2( pos.x - 1 , pos.y );
		case Direction.Right:
			return new IntVector2( pos.x + 1 , pos.y );
		default:
			throw new ArgumentOutOfRangeException();
		}
	}

	/// <summary>
	/// Gets the piece located at the given position.
	/// </summary>
	/// <returns>The piece at the given position, null if none.</returns>
	/// <param name="p">the position</param>
	GameObject GetPieceByPosition(IntVector2 p) {
		return board[ p.x , p.y ];
	}

	/// <summary>
	/// Finds the position of the given piece.
	/// </summary>
	/// <returns>The position of the given piece</returns>
	/// <param name="piece">the piece</param>
	IntVector2 FindPiecePosition(GameObject piece) {
		for( var i = 0; i < numberOfRows; i++) {
			for( var j = 0; j < numberOfColumns; j++ ) {
				if( board[i,j] == piece ) {
					return new IntVector2( i , j );
				}
			}
		}
		return null;
 	}

	/// <summary>
	/// Resets the black box.
	/// </summary>
	void ResetBlackBox() {
		sourcePlayerWin.Play();

		//reset board properties
		board = new GameObject[numberOfRows, numberOfColumns];
		if( blackBoxBandit != null ) {
			Destroy( blackBoxBandit );
			blackBoxBandit = null;
		}
		if( goldenKey != null ) {
			Destroy( goldenKey );
			goldenKey = null;
		}
		goldenKeyLocation = null;
		if( exit != null ) {
			Destroy( exit );
			exit = null;
		}
		exitLocation = null;
		if( drones != null ) {
			foreach(var d in drones ) {
				Destroy( d );
			}
		}
		drones = new List<GameObject>();
		if( walls != null ) {
			foreach(var w in walls ) {
				Destroy( w );
			}
		}
		walls = new List<GameObject>();
		doesBanditHaveKey = false;

		//setup non-random board pieces (the black box bandit, the exit and the walls)
		IntVector2 initialBanditLocation = new IntVector2( 0 , 0 );
		var emptyTileLocations = new List<IntVector2>();
		var rotation = Quaternion.identity;
		for (var i = 0; i < numberOfRows; i++) {
			for (var j = 0; j < numberOfColumns; j++){
				var position = FromGridPositionToScreenPosition(i,j);
				if ( i % 2 != 0 && j % 2 != 0 ) {
					board[i,j] = (GameObject) Instantiate (wallTileTemplate, position, rotation);
					walls.Add( board[i,j] );
				} else {
					board[i,j] = (GameObject) Instantiate (floorTileTemplate, position, rotation);
					if( i == initialBanditLocation.x && j == initialBanditLocation.y ) {
						board[i,j] = blackBoxBandit = (GameObject) Instantiate (blackBoxBanditTemplate, position, rotation);
					} else if( i == numberOfRows - 1 && j == numberOfColumns - 1) {
						exit = (GameObject) Instantiate (exitTileTemplate, position, rotation);
						exitLocation = new IntVector2( i , j );
					}  else {
						emptyTileLocations.Add( new IntVector2( i , j ) );
					}
				}
			}
		}

		//setup random board pieces (the golden key and the drones) in the empty tiles
		ShuffleList( emptyTileLocations );
		goldenKey = (GameObject) Instantiate (goldenKeyTemplate, FromGridPositionToScreenPosition(emptyTileLocations[ 0 ].x , emptyTileLocations[ 0 ].y), rotation);
		goldenKeyLocation = new IntVector2( emptyTileLocations[ 0 ].x , emptyTileLocations[ 0 ].y);
		emptyTileLocations.Remove( emptyTileLocations[ 0 ] );


		var droneSpawnLocations = emptyTileLocations.Where( p => ComputeManhattanDistance( p, initialBanditLocation ) >= minimumManhattanDistanceBetweenBanditAndDroneSpawns ).ToList();
		var evenDistanceSpawnLocations = droneSpawnLocations.Where(  p => ComputeManhattanDistance( p, initialBanditLocation ) % 2 == 0  ).ToList();
		var oddDistanceSpawnLocations = droneSpawnLocations.Where(  p => ComputeManhattanDistance( p, initialBanditLocation ) % 2 != 0  ).ToList();
		ShuffleList( evenDistanceSpawnLocations );
		ShuffleList( oddDistanceSpawnLocations );
		for(var i = 0 ; i < numberOfDrones; i++ ) {
			List<IntVector2> locations;
			if( i % 2 == 0 && evenDistanceSpawnLocations.Count > 0 ) {
				locations = evenDistanceSpawnLocations;
			} else if ( i % 2 != 0 && oddDistanceSpawnLocations.Count > 0 ) {
				locations = oddDistanceSpawnLocations;
			}else {
				return;
			}
			IntVector2 gridPosition = locations[ 0 ];
			Vector2 screenPosition = FromGridPositionToScreenPosition(gridPosition.x , gridPosition.y);
			GameObject newDrone = (GameObject) Instantiate (evenDroneTemplate, screenPosition, rotation);
			board[gridPosition.x , gridPosition.y ] = newDrone;
			drones.Add( newDrone );
			locations.RemoveAt( 0 );
		}
		UpdateDroneColors();
	}

	/// <summary>
	/// Computes the screen position of the given grid position represented by i and j.
	/// </summary>
	/// <returns>The screen position</returns>
	/// <param name="i">grid row index</param>
	/// <param name="j">grid column index</param>
	Vector2 FromGridPositionToScreenPosition(int i, int j) {
		return new Vector2( i - numberOfRows / 2 , j - numberOfColumns / 2 );
	}

	/// <summary>
	/// Shuffles the given list.
	/// </summary>
	/// <param name="ls">the list to shuffle</param>
	void ShuffleList(IList ls) {
		for (int i = 0; i < ls.Count; i++) {
			var temp = ls[i];
			int randomIndex = UnityEngine.Random.Range(i, ls.Count);
			ls[i] = ls[randomIndex];
			ls[randomIndex] = temp;
		}
	}
}
