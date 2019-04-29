using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using InControl;

namespace Assets.Scripts.Controls
{
    public class ExplorerActions : PlayerActionSet
    {
        public PlayerAction Select;
        public PlayerAction Pause;

        public PlayerAction MoveLeft;
        public PlayerAction MoveRight;
        public PlayerAction MoveDown;
        public PlayerAction MoveUp;
        public PlayerTwoAxisAction Move;

        public PlayerAction TurnLeft;
        public PlayerAction TurnRight;
        public PlayerAction TurnDown;
        public PlayerAction TurnUp;
        public PlayerTwoAxisAction Turn;


        public PlayerAction UseSelectedItem;
        public PlayerAction DropSelectedItem;
        public PlayerAction Attack;
        public PlayerAction ToggleFlashLight;
        public PlayerAction SelectItemLeft;
        public PlayerAction SelectItemRight;
        public PlayerAction SwapItemLeft;
        public PlayerAction SwapItemRight;

        public ExplorerActions()
        {
            Select = CreatePlayerAction("Select");
            Pause = CreatePlayerAction("Pause");

            MoveLeft = CreatePlayerAction("Move Left");
            MoveRight = CreatePlayerAction("Move Right");
            MoveDown = CreatePlayerAction("Move Down");
            MoveUp = CreatePlayerAction("Move Up");
            Move = CreateTwoAxisPlayerAction(MoveLeft, MoveRight, MoveDown, MoveUp);

            TurnLeft = CreatePlayerAction("Turn Left");
            TurnRight = CreatePlayerAction("Turn Right");
            TurnDown = CreatePlayerAction("Turn Down");
            TurnUp = CreatePlayerAction("Turn Up");
            Turn = CreateTwoAxisPlayerAction(TurnLeft, TurnRight, TurnDown, TurnUp);

            UseSelectedItem = CreatePlayerAction("Use Selected Item");
            DropSelectedItem = CreatePlayerAction("Drop Selected Item");
            Attack = CreatePlayerAction("Attack");
            ToggleFlashLight = CreatePlayerAction("Toggle Flashlight");
            SelectItemLeft = CreatePlayerAction("Select Item Left");
            SelectItemRight = CreatePlayerAction("Select Item Right");
            SwapItemLeft = CreatePlayerAction("Swap Item Left");
            SwapItemRight = CreatePlayerAction("Swap Item Right");


        }
    }
}
