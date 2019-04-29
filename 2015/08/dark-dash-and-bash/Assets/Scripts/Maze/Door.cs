using UnityEngine;
using System.Collections;

public class Door : System.Object {
	/* The type of this door. */
	public DoorType TheDoorType {get; set;}
	/* The first room this door is connected to. */
	public Room FirstRoom { get; set; }
	/* The second room this door is connected to. */
	public Room SecondRoom { get; set; }
	
	public Door(DoorType dt) {
		this.TheDoorType = dt;
	}
	public Door() : this(DoorType.Black) {}
}
