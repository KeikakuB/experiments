using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.Text;
using System.Linq;

public class Maze : System.Object {
	/* The 2D array of rooms. */
	public Room[][] Rooms;
	/* The width of the dungeon in rooms. */
	public int Width {get; private set;}
	/* The height of the dungeon in rooms.*/
	public int Height {get; private set;}

    public double OpenDoorChance { get; private set; }

	public Maze() : this(4, 0.4) { }

	public Maze(int size, double openDoorChance) {
		this.Width = size;
		this.Height = size;
        this.OpenDoorChance = openDoorChance;
		Generate();
	}
	/* Generate a solveable dungeon. */
	public void Generate() {
		do {
			//initialize rooms
			this.Rooms = new Room[Height][];
			for(int k = 0; k < Height; k++) {
				Rooms[k] = new Room[Width];
			}
			for(int i = 0; i < Height; i++) {
				for(int j = 0; j < Width; j++) {
					Rooms[i][j] = new Room(j, i);
				}
			}
			//initialize doors
			SetInitialDoors();
			//generate a simple maze using Aldous-Broder
			GenerateBasicMaze();
			//try to add the orb of light and the exit to the maze
		} while( !AddGameElements() );
        //TODO: put this back in maybe
		//add connections to turn the simple maze into a braided maze
		AddConnections();
	}
	/* Set the doors/passages correctly between the rooms.  */
	private void SetInitialDoors() {
		//loop through rooms setting the connecting doors
		//NB: some doors are set multiple times (overwritten) for simplicity
		for(int i = 0; i < Height; i++) {
			for(int j = 0; j < Width; j++) {
				Room r = Rooms[i][j];
				foreach( CardinalDirection dir in Enum.GetValues(typeof(CardinalDirection))) {
					Room next = GetRoomInDirection(r, dir);
					SetDoorBetween(r, dir, next);
				}
			}
		}
	}
	/* 
	 * Generate a uniform spanning tree maze using the Aldous-Broder algorithm. 
	 * Algorithm explained here: http://weblog.jamisbuck.org/2011/1/17/maze-generation-aldous-broder-algorithm
	 */
	private void GenerateBasicMaze() {
		System.Random rnd = new System.Random();
		//find an initial room
		int x = rnd.Next(0, Width);
		int y = rnd.Next(0, Height);
		Room current = Rooms[y][x];
		current.Visited = true;
		//set it to be the entrance
		current.TheRoomType = RoomType.Entrance;
		int remaining = Width * Height - 1;
		//build the maze
		CardinalDirection[] directions = Enum.GetValues(typeof(CardinalDirection)).Cast<CardinalDirection>().ToArray();
		CardinalDirection[] cloned;
		while(remaining > 0) {
			cloned = new CardinalDirection[directions.Length];
			Array.Copy(directions, cloned, directions.Length);
			while(cloned.Count() > 0) {
				//get random direction from set of unused directions
				CardinalDirection dir = cloned[rnd.Next(0, cloned.Count())];
				int nx = x + GetDeltaX(dir);
				int ny = y + GetDeltaY(dir);
				if(nx >= 0 && ny >= 0 && nx < Width && ny < Height) {
					Room next = Rooms[ny][nx];
					if(!next.Visited) {
						next.Visited = true;
						current.SetDoorType(dir, DoorType.Open);
						next.SetDoorType(GetOppositeDirection(dir), DoorType.Open);
						remaining -= 1;
					}
					x = nx;
					y = ny;
					current = Rooms[y][x];
					break;
				}
			}
		}

	}
	/* Add the block doors, the bullets and the exit room to the maze. Returns false upon failure, true upon success*/
	private bool AddGameElements() {
		System.Random rnd = new System.Random();
		CardinalDirection[] directions = Enum.GetValues(typeof(CardinalDirection)).Cast<CardinalDirection>().ToArray();
		//make an array with all the special rooms we must add to the maze
		RoomType[] rts = { RoomType.OrbOfLight, RoomType.Exit};
		//get leaf rooms
		IList<Room> leafRooms = new List<Room>();
		for(int i = 0; i < Height; i++) {
			for(int j = 0; j < Width; j++) {
				Room r = Rooms[i][j];
				if(r.TheRoomType != RoomType.Entrance && r.IsLeafRoom()) {
					leafRooms.Add(r);
				}
			}
		}
		//if not enough leaf rooms
		if(leafRooms.Count < rts.Length) {
			return false;
		}
		//place each special room into a random leaf
		foreach(RoomType rt in rts) {
			//pick random leaf room
			int idx = rnd.Next(0, leafRooms.Count());
			Room r = leafRooms.ElementAt(idx);
			//remove the leaf room from the list to avoid picking it twice
			leafRooms.RemoveAt(idx);
			r.TheRoomType = rt;
		}
		return true;
	}
	/* Add connections to create a braided maze structure. */
	private void AddConnections() {
		System.Random rnd = new System.Random();
		CardinalDirection[] directions = Enum.GetValues(typeof(CardinalDirection)).Cast<CardinalDirection>().ToArray();
        HashSet<Door> checkedDoors = new HashSet<Door>();
        for (int i = 0; i < Height; i++)
        {
            for (int j = 0; j < Width; j++)
            {
                Room r = Rooms[i][j];
                foreach (CardinalDirection dir in Enum.GetValues(typeof(CardinalDirection)))
                {
                    Door d = r.GetDoor(dir);
                    if (checkedDoors.Contains(d) ||
                        (                        
                            (d.TheDoorType != DoorType.Black) ||                                      //is the door not a black/wall door?
                            (i == 0 && dir == CardinalDirection.North) ||                 //is the door out of bounds?
                            (i == Height - 1 && dir == CardinalDirection.South) ||        //is the door out of bounds?
                            (j == 0 && dir == CardinalDirection.West) ||                  //is the door out of bounds?
                            (j == Width - 1 && dir == CardinalDirection.East)             //is the door out of bounds?
                        ) )
                    {
                        continue;
                    }
                    checkedDoors.Add(d);
                    if (rnd.NextDouble() < OpenDoorChance)
                    {
                        d.TheDoorType = DoorType.Open;
                    }
                }
            }
        }
	}
	/* Returns the room adjacent to the given room in the given direction. */
	private Room GetRoomInDirection(Room r, CardinalDirection dir) {
		Room next = null;
		int x = r.x + GetDeltaX(dir);
		int y = r.y + GetDeltaY(dir);
		if(x >= 0 && x < Width && y >= 0 && y < Height) {
			next = Rooms[y][x];
		}
		return next;
	}
	private void SetDoorBetween(Room r1, CardinalDirection toward, Room r2) {
		SetDoorBetween(r1, toward, r2, DoorType.Black);
	}
	/* Add a door between two adjacent rooms with the direction vector going from r1 to r2. */
	private void SetDoorBetween(Room r1, CardinalDirection toward, Room r2, DoorType dt) {
		Door d = new Door(dt);
		if(r1 != null) {
			r1.SetDoor(toward, d);
		}
		if(r2 != null) {
			r2.SetDoor(GetOppositeDirection(toward), d);
		}
		d.FirstRoom = r1;
		d.SecondRoom = r2;
	}
	/* Returns the delta x associated with the given cardinal direction. */
	private int GetDeltaX(CardinalDirection dir) {
		switch(dir) {
		case CardinalDirection.North:
			return 0;
		case CardinalDirection.East:
			return 1;
		case CardinalDirection.South:
			return 0;
		case CardinalDirection.West:
			return -1;
		}
		throw new ArgumentException();
	}
	/* Returns the delta y associated with the given cardinal direction. */
	private int GetDeltaY(CardinalDirection dir) {
		switch(dir) {
		case CardinalDirection.North:
			return -1;
		case CardinalDirection.East:
			return 0;
		case CardinalDirection.South:
			return 1;
		case CardinalDirection.West:
			return 0;
		}
		throw new ArgumentException();
	}
	
	/* Returns the opposite direction of the given cardinal direction. */
	private CardinalDirection GetOppositeDirection(CardinalDirection dir) {
		switch(dir) {
		case CardinalDirection.North:
			return CardinalDirection.South;
		case CardinalDirection.East:
			return CardinalDirection.West;
		case CardinalDirection.South:
			return CardinalDirection.North;
		case CardinalDirection.West:
			return CardinalDirection.East;
		}
		throw new ArgumentException();
	}

	/* 
	   Returns the string representation of this maze's current state.
	   NB: Does not show entrance/exit/bullets/special-rooms, only maze structure.
	*/
	public override string ToString() {
		StringBuilder str = new StringBuilder("");
		for(int i = 0; i < Height; i++) {
			StringBuilder line = new StringBuilder("");
			for(int j = 0; j < Width; j++) {
				Room r = Rooms[i][j];
				if(r.GetDoorType(CardinalDirection.North) == DoorType.Open) {
					line.Append("x|x   ");
				}
				else {
					line.Append("xxx   ");
				}
			}
			str.AppendLine(line.ToString());
			line = new StringBuilder("");
			for(int j = 0; j < Width; j++) {
				Room r = Rooms[i][j];
				bool westOpen = r.GetDoorType(CardinalDirection.West) == DoorType.Open;
				bool eastOpen = r.GetDoorType(CardinalDirection.East) == DoorType.Open;
				if(westOpen && eastOpen) {
					line.Append("-+-   ");
				}
				else if(westOpen) {
					line.Append("-+x   ");
				}
				else if(eastOpen) {
					line.Append("x+-   ");
				}
				else {
					line.Append("x+x   ");
				}
			}
			str.AppendLine(line.ToString());
			line = new StringBuilder("");
			for(int j = 0; j < Width; j++) {
				Room r = Rooms[i][j];
				if(r.GetDoorType(CardinalDirection.South) == DoorType.Open) {
					line.Append("x|x   ");
				}
				else {
					line.Append("xxx   ");
				}
			}
			str.AppendLine(line.ToString());
		}
		return str.ToString();
	}
}
