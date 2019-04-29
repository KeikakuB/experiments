using UnityEngine;
using System.Collections;
using System;

public class Room : System.Object {
	/* The x index of the room. */
	public readonly int x;
	/* The y index of the room. */
	public readonly int y;
	/* The generic bool member variable used for Aldous and DFS. */
	public bool Visited {get; set;}
	/* The room type of this room. */
	public RoomType TheRoomType {get; set;}
	/* The set of doors attached to this room. */
	private Door[] doors;
	
	public Room(int x, int y, RoomType rt) {
		Visited = false;
		//set x and y coords
		this.x = x;
		this.y = y;
		//initialize doors array
		this.doors = new Door[Enum.GetNames(typeof(CardinalDirection)).Length];
		//set the room type
		TheRoomType = rt;
	}
	public Room(int x, int y) : this(x, y, RoomType.Normal) {}

	/* Returns true if the room has a single open doorway, else false. */
	public bool IsLeafRoom() {
		int openDoorwayCount = 0;
		foreach(Door d in doors) {
			if(d.TheDoorType == DoorType.Open) { openDoorwayCount++; }
		}
		return openDoorwayCount == 1;
	}
	/* Returns an open door if there is one, else returns null. */
	public Door GetAnOpenDoor() {
		foreach(Door d in doors) {
			if(d.TheDoorType == DoorType.Open) { return d; }
		}
		return null;
	}

	/* Returns the door attached to this room in the given cardinal direction. */
	public Door GetDoor(CardinalDirection dir) {
		return doors[(int)dir];
	}
	/* Set the door attached to this room to the given cardinal direction. */
	public void SetDoor(CardinalDirection dir, Door d) {
		doors[(int)dir] = d;
	}
	/* Get the door type of the door attached to this room in the given cardinal direction. */
	public DoorType GetDoorType(CardinalDirection dir) {
		return doors[(int) dir].TheDoorType;
	}
	/* Set the door type of the door attached to this room in the given cardinal direction. */
	public void SetDoorType(CardinalDirection dir, DoorType dc) {
		doors[(int)dir].TheDoorType = dc;
	}

}
