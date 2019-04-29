using UnityEngine;
using System.Collections;
using Assets.Scripts.Controls;
using InControl;

public class ExplorerController : MonoBehaviour {
    public GameObject ShovelHeadTemplate;
    public float ShovelInitialForceFactor;
    public float SpeedFactor;
    public float SpeedFactorWithOrb;
    public float AttackDelay;
    public float StunTime;
    public float InvulnerabilityTime;
    public float DelayBeforeCanPickupDroppedItem;
    public Light[] Flashlights;
    public AudioSource ShovelSwingSound;
    public AudioSource ShovelHitSound;

    private ExplorerActions explorerActions;
    public bool IsStunned { get; private set; }
    private bool isInvulnerable = false;
    private bool canAttack = true;
    public bool CannotPickupOrb { get; private set; }
    private bool hasInputDeviceBeenSet = false;

    private OrbOfLight carriedOrbOfLight = null;
    public bool IsCarryingOrbOfLight
    {
        get
        {
            return carriedOrbOfLight != null;
        }
    }
    

	// Use this for initialization
	void Start () {
        explorerActions = new ExplorerActions();

        explorerActions.Select.AddDefaultBinding(InputControlType.Select);
        explorerActions.Pause.AddDefaultBinding(InputControlType.Start);

        explorerActions.MoveLeft.AddDefaultBinding(InputControlType.LeftStickLeft);
        explorerActions.MoveRight.AddDefaultBinding(InputControlType.LeftStickRight);
        explorerActions.MoveDown.AddDefaultBinding(InputControlType.LeftStickDown);
        explorerActions.MoveUp.AddDefaultBinding(InputControlType.LeftStickUp);

        explorerActions.TurnLeft.AddDefaultBinding(InputControlType.RightStickLeft);
        explorerActions.TurnRight.AddDefaultBinding(InputControlType.RightStickRight);
        explorerActions.TurnDown.AddDefaultBinding(InputControlType.RightStickDown);
        explorerActions.TurnUp.AddDefaultBinding(InputControlType.RightStickUp);
        
        explorerActions.UseSelectedItem.AddDefaultBinding(InputControlType.Action1);
        explorerActions.DropSelectedItem.AddDefaultBinding(InputControlType.Action2);
        explorerActions.Attack.AddDefaultBinding(InputControlType.RightBumper);
        explorerActions.ToggleFlashLight.AddDefaultBinding(InputControlType.Action4);

        explorerActions.SelectItemLeft.AddDefaultBinding(InputControlType.LeftTrigger);
        explorerActions.SelectItemRight.AddDefaultBinding(InputControlType.RightTrigger);
	}
	
	// Update is called once per frame
	void Update () {
        if (explorerActions.Select.IsPressed
            && explorerActions.Pause.IsPressed)
        {
            Application.LoadLevel(Application.loadedLevel);
        }

        if (!hasInputDeviceBeenSet || IsStunned)
        {
            return;
        }

        if (explorerActions.Attack.WasPressed)
        {
            PerformAttack();
        }
        if (explorerActions.ToggleFlashLight.WasPressed)
        {
            PerformToggleFlashlight();
        }

        if (explorerActions.DropSelectedItem.WasPressed)
        {
            PerformDropSelectedItem();
        }
	}

    void FixedUpdate()
    {
        if (!hasInputDeviceBeenSet || IsStunned)
        {
            return;
        }
        if (explorerActions.Move.IsPressed)
        {
            PerformMove(explorerActions.Move.Value);
            PerformTurn(explorerActions.Move.Value);
        }

        if (explorerActions.Turn.IsPressed)
        {
            PerformTurn(explorerActions.Turn.Value);
        }
    }

    public void SetDevice(InputDevice d)
    {
        explorerActions.Device = d;
        hasInputDeviceBeenSet = true;
    }

    void PerformMove(Vector2 moveDir)
    {
        Rigidbody rb = GetComponent<Rigidbody>();
        float speed = SpeedFactor;
        if (carriedOrbOfLight != null)
        {
            speed = SpeedFactorWithOrb;
        }
        float deltaX = speed * moveDir.x;
        float deltaZ = speed * moveDir.y;
        rb.AddForce(deltaX, 0f, deltaZ);
    }

    void PerformTurn(Vector2 turnDir)
    {
        Vector3 target = new Vector3(turnDir.x, turnDir.y, 0);
        Vector3 dir = target;
        float angle = -90 + (Mathf.Atan2(dir.y, dir.x) * Mathf.Rad2Deg);
        transform.rotation = Quaternion.AngleAxis(angle, Vector3.down);
    }

    void PerformAttack()
    {
        if (canAttack)
        {
            ShovelSwingSound.Play();
            Vector3 forwardOffset = transform.forward * 1f;
            GameObject shovel = (GameObject) Instantiate(ShovelHeadTemplate, transform.position + forwardOffset, Quaternion.identity);
            shovel.GetComponent<ShovelHead>().Parent = this.gameObject;
            Rigidbody rbForShovel = shovel.GetComponent<Rigidbody>();
            rbForShovel.AddForce(forwardOffset * ShovelInitialForceFactor);
            canAttack = false;
            Invoke("RecoverFromAttackDelay", AttackDelay);
        }
    }

    void PerformToggleFlashlight()
    {
        foreach (Light l in Flashlights)
        {
            l.enabled = !l.enabled;
        }
    }

    void PerformDropSelectedItem()
    {
        //TODO: make this do what it should actually do
        if (carriedOrbOfLight != null)
        {
            DropCarriedOrbOfLight();
            CannotPickupOrb = true;
            Invoke("EnableOrbPickup", DelayBeforeCanPickupDroppedItem);
        }
    }

    void DropCarriedOrbOfLight()
    {
        if (carriedOrbOfLight != null)
        {
            carriedOrbOfLight.transform.position = new Vector3(transform.position.x, transform.position.y, transform.position.z);
            carriedOrbOfLight.OnRelease();
            carriedOrbOfLight = null;
        }
    }

    void GrabOrbOfLight(OrbOfLight orb)
    {
        orb.transform.position = new Vector3(transform.position.x, transform.position.y + 1f, transform.position.z);
        orb.transform.parent = transform;
        carriedOrbOfLight = orb;
    }

    public void OnTouchOrbOfLight(OrbOfLight orb)
    {
        GrabOrbOfLight(orb);
    }

    public void OnHit()
    {
        if (!isInvulnerable)
        {
            foreach (Light l in Flashlights)
            {
                l.enabled = false;
            }
            ShovelHitSound.Play();
            IsStunned = true;
            isInvulnerable = true;
            Invoke("RecoverFromStun", StunTime);
            if (carriedOrbOfLight != null)
            {
                DropCarriedOrbOfLight();
            }
        }
    }
    void RecoverFromStun()
    {
        IsStunned = false;
        Invoke("DisableInvulnerability", InvulnerabilityTime);
    }

    void RecoverFromAttackDelay()
    {
        canAttack = true;
    }

    void DisableInvulnerability()
    {
        isInvulnerable = false;
    }

    void EnableOrbPickup()
    {
        CannotPickupOrb = false;
    }
}
