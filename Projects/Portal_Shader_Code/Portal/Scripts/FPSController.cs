using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FPSController : MonoBehaviour 
{
    //Public
    [Header("Move")]
    public float walkSpeed = 3;
    public float runSpeed = 6;
    public float smoothMoveTime = 0.1f;
    public float jumpForce = 8;
    public float gravity = 18;

    public bool lockCursor;
    public float mouseSensitivity = 10;
    public Vector2 pitchMinMax = new Vector2 (-40, 85);
    public float rotationSmoothTime = 0.1f;

    float yaw;
    float pitch;

    [Header("Animation")]
    public float acceleration = 4f;
    public float deceleration = 4f;

    //Private
    CharacterController controller;
    Camera cam;
    
    float smoothYaw;
    float smoothPitch;
    float yawSmoothV;
    float pitchSmoothV;
    float verticalVelocity;
    Vector3 velocity;
    Vector3 smoothV;
    bool jumping;
    float lastGroundedTime;

    //Private Anim
    Animator anim;
    float velocityW = 0.0f;
    float velocityH = 0.0f;
    int VelocityHash;
    int Run;

    void Start () 
    {
        //Lock cursor
        cam = Camera.main;
        if (lockCursor) {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }

        controller = GetComponent<CharacterController> ();

        yaw = transform.eulerAngles.y;
        pitch = cam.transform.localEulerAngles.x;
        smoothYaw = yaw;
        smoothPitch = pitch;

        anim = GetComponent<Animator>();
        VelocityHash = Animator.StringToHash("Move");
        Run = Animator.StringToHash("Run");
    }

    void Update ()
    {
        //Move
        Vector2 input = new Vector2 (Input.GetAxisRaw ("Horizontal"), Input.GetAxisRaw ("Vertical"));
        Vector3 inputDir = new Vector3 (input.x, 0, input.y).normalized;
        Vector3 worldInputDir = transform.TransformDirection (inputDir);
        bool forwardPressed = Input.GetKey("w");

        if (forwardPressed && velocityW < 1.0f)
        {
            velocityW += Time.deltaTime * acceleration;
        }

        if (!forwardPressed && velocityW > 0.0f)
        {
            velocityW -= Time.deltaTime * deceleration;
        }
        if (!forwardPressed && velocityW < 0.0f)
        {
            velocityW = 0.0f;
        }
        anim.SetFloat(VelocityHash, velocityW);

        //Run
        float currentSpeed = (Input.GetKey (KeyCode.LeftShift)) ? runSpeed : walkSpeed;
        Vector3 targetVelocity = worldInputDir * currentSpeed;
        velocity = Vector3.SmoothDamp (velocity, targetVelocity, ref smoothV, smoothMoveTime);
        bool runPressd = (Input.GetKey (KeyCode.LeftShift));

        if (runPressd && velocityH < 1.0f)
        {
            velocityH += Time.deltaTime * acceleration;
        }

        if (!runPressd && velocityH > 0.0f)
        {
            velocityH -= Time.deltaTime * deceleration;
        }
        if (!runPressd && velocityH < 0.0f)
        {
            velocityH = 0.0f;
        }
        anim.SetFloat(Run, velocityH);
        //ravity
        verticalVelocity -= gravity * Time.deltaTime;
        velocity = new Vector3 (velocity.x, verticalVelocity, velocity.z);

        var flags = controller.Move (velocity * Time.deltaTime);

        if (flags == CollisionFlags.Below) 
        {
            jumping = false;
            lastGroundedTime = Time.time;
            verticalVelocity = 0;
        }

        //Jump
        if (Input.GetKeyDown (KeyCode.Space)) 

        {
            float timeSinceLastTouchedGround = Time.time - lastGroundedTime;
            if (controller.isGrounded || (!jumping && timeSinceLastTouchedGround < 0.15f)) {
                jumping = true;
                verticalVelocity = jumpForce;
            }
            anim.SetBool("Jump", true);
        }
         if (!Input.GetKey(KeyCode.Space)) 
        {
          anim.SetBool("Jump", false);
        }


        float mX = Input.GetAxisRaw ("Mouse X");
        float mY = Input.GetAxisRaw ("Mouse Y");

        float mMag = Mathf.Sqrt (mX * mX + mY * mY);
        if (mMag > 5) {
            mX = 0;
            mY = 0;
        }

        //Camera control, angle cam control
        yaw += mX * mouseSensitivity;
        pitch -= mY * mouseSensitivity;
        pitch = Mathf.Clamp (pitch, pitchMinMax.x, pitchMinMax.y);
        //Smooth angle rotate
        smoothPitch = Mathf.SmoothDampAngle (smoothPitch, pitch, ref pitchSmoothV, rotationSmoothTime);
        smoothYaw = Mathf.SmoothDampAngle (smoothYaw, yaw, ref yawSmoothV, rotationSmoothTime);
        //transfer cam position
        transform.eulerAngles = Vector3.up * smoothYaw;
        cam.transform.localEulerAngles = Vector3.right * smoothPitch;

    }
}