using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using System.Linq;
using InControl;

public class MazeMaster : MonoBehaviour {
    private const string MAP_SIZE = "MAP_SIZE";
	/* The logical maze representation. */
	private Maze maze;
    public float OpenDoorChance;

	public GameObject[] Explorers;
    private InputDevice[] Devices = new InputDevice[4];

	/* The template for the room foundation prefab. */
	public GameObject RoomFoundationTemplate;
    /* The size of the side of the square shaped rooms. */
    public float RoomTemplateSideSize;
    public GameObject[] RoomSceneryTemplates;
    public GameObject RoomLightTemplate;
    public GameObject SpecialRoomLightTemplate;
	/* The template for the entrance room addon prefab. */
	public GameObject EntranceAddonTemplate;
	/* The template for the exit room addon prefab. */
	public GameObject ExitAddonTemplate;
    /* The template for the Orb of Light room addon prefab. */
    public GameObject OrbOfLightTemplate;
	
	/* The template for the blocked door prefab. */
	public GameObject DoorTemplate;

	// Use this for initialization
	void Start () {
        Time.timeScale = 1f;
        int mapSize = 3;
        if (PlayerPrefs.HasKey(MAP_SIZE))
        {
            mapSize = PlayerPrefs.GetInt(MAP_SIZE);
        }
        else
        {
            PlayerPrefs.SetInt(MAP_SIZE, mapSize);
            PlayerPrefs.Save();
        }
		SetTheMaze(mapSize);
	}

    void Update()
    {
        if (InputManager.ActiveDevice != InputDevice.Null)
        {
            bool isActiveDeviceIsRegistered = false;
            for (int i = 0; i < Devices.Length; i++)
            {
                if (Devices[i] == InputManager.ActiveDevice)
                {
                    isActiveDeviceIsRegistered = true;
                    break;
                }
            }
            if (!isActiveDeviceIsRegistered)
            {
                for (int i = 0; i < Devices.Length; i++)
                {
                    if (Devices[i] == null)
                    {
                        Devices[i] = InputManager.ActiveDevice;
                        Explorers[i].GetComponent<ExplorerController>().SetDevice(Devices[i]);
                        break;
                    }
                }
            }
        }
        int mapSize = 0;
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            mapSize = 2;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            mapSize = 3;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha4))
        {
            mapSize = 4;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha5))
        {
            mapSize = 5;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha6))
        {
            mapSize = 6;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha7))
        {
            mapSize = 7;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha8))
        {
            mapSize = 8;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha9))
        {
            mapSize = 9;
        }
        if (mapSize > 1)
        {
            PlayerPrefs.SetInt(MAP_SIZE, mapSize);
            PlayerPrefs.Save();
            Application.LoadLevel(Application.loadedLevel);
        }
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Application.Quit();
        }
    }

	/* Set the maze up. */
	public void SetTheMaze(int mapSize) {
		//initialize the logical maze
        maze = new Maze(mapSize, OpenDoorChance);
		//create the in-game representation of the logical maze
		ConstructPhysicalMaze();
		//print the maze's string representation for debugging
		Debug.Log(maze.ToString());
	}

	void ConstructPhysicalMaze() {
		//create a hashset for the doors that have already been placed
		HashSet<Door> doorsPlaced = new HashSet<Door>();
		//loop through each room in the maze
		for(int i = 0; i < maze.Height; i++) {
			for(int j = 0; j < maze.Width; j++) {
				//get the room
				Room r = maze.Rooms[i][j];
				//build the room
				RoomType rt = r.TheRoomType;
                BuildRoomAt(RoomFoundationTemplate, i, j);
                if (rt == RoomType.Normal)
                {
                    BuildRandomSceneryAt(i, j);
                }
				GameObject roomTemplate = null;
				if(rt == RoomType.Entrance) {
					roomTemplate = EntranceAddonTemplate;
					//move the characters above the entrance room
					MoveCharactersTo(i, j);
				} else if(rt == RoomType.Exit) {
					roomTemplate = ExitAddonTemplate;
                }
                else if (rt == RoomType.OrbOfLight)
                {
                    roomTemplate = OrbOfLightTemplate;
                }
                if (roomTemplate != null)
                {
                    BuildRoomAt(roomTemplate, i, j);
                }
                if (rt == RoomType.Normal)
                {
                    BuildNormalRoomLightsAt(i, j);
                }
                else if (rt == RoomType.Exit)
                {
                    BuildSpecialRoomLightsAt(i, j);
                }
				//build the doors for this room
				foreach(CardinalDirection dir in System.Enum.GetValues(typeof(CardinalDirection))) {
					Door d = r.GetDoor(dir);
					GameObject doorTemplate = null;
					//if the door d has not been placed yet
					if( d.TheDoorType == DoorType.Black && !doorsPlaced.Contains(d)) {
                        doorTemplate = DoorTemplate;
						if(doorTemplate != null) {
							BuildDoorAt(doorTemplate, dir, i, j);
						}
						doorsPlaced.Add(d);
					}
				}
			}
		}
	}
	/* Move the player character to the given grid location. */
	void MoveCharactersTo(int i, int j) {
        foreach (GameObject g in Explorers)
        {
            g.transform.position = transform.position + new Vector3(i * RoomTemplateSideSize, g.transform.position.y, j * RoomTemplateSideSize);
            Vector2 randDir = Random.insideUnitCircle;
            float randDistance = Random.Range(0f, 5f);
            randDir *= randDistance;
            g.transform.Translate(new Vector3(randDir.x, 0f, randDir.y));
            g.transform.Rotate(Vector3.up, Random.Range(0, 360));
        }
	}
	/* Instantiate a copy of the given room template at the given grid location. */
	void BuildRoomAt(GameObject room, int i, int j) {
		GameObject.Instantiate(
            room, 
            transform.position + new Vector3(i * RoomTemplateSideSize, 0, j * RoomTemplateSideSize), 
            Quaternion.identity);
	}
    void BuildRandomSceneryAt(int i, int j)
    {
        GameObject.Instantiate(
            RoomSceneryTemplates[Random.Range(0, RoomSceneryTemplates.Length)], 
            transform.position + new Vector3(i * RoomTemplateSideSize, 0, j * RoomTemplateSideSize), 
            Quaternion.identity);
    }
    void BuildNormalRoomLightsAt(int i, int j)
    {
        GameObject.Instantiate(
            RoomLightTemplate,
            transform.position + new Vector3(i * RoomTemplateSideSize, 0, j * RoomTemplateSideSize),
            Quaternion.identity);
    }
    void BuildSpecialRoomLightsAt(int i, int j)
    {
        GameObject.Instantiate(
            SpecialRoomLightTemplate,
            transform.position + new Vector3(i * RoomTemplateSideSize, 0, j * RoomTemplateSideSize),
            Quaternion.identity);
    }
	/* Instantiate a copy of the given door at the given grid location and towards the given cardinal direction. */
	void BuildDoorAt(GameObject door, CardinalDirection dir, int i, int j) {
		Vector3 offset = new Vector3(i * RoomTemplateSideSize, 0, j * RoomTemplateSideSize);
        float num = RoomTemplateSideSize / 2f;
		switch(dir) {
		case CardinalDirection.North:
			offset.x += -num;
			break;
		case CardinalDirection.South:
			offset.x += num;
			break;
		case CardinalDirection.East:
			offset.z += num;
			break;
		case CardinalDirection.West:
			offset.z += -num;
			break;
		}
		GameObject.Instantiate(door, transform.position + offset, Quaternion.identity);
	}
}
