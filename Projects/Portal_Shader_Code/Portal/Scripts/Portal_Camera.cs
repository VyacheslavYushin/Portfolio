using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Portal_Camera : MonoBehaviour
{
    public Transform playerCamera;
    public Transform portal;
    public Camera portalCam;
    public Transform otherPortal;
    public Camera playerCam;


    void Update()
    {
        Vector3 playerOffsetFromPortal = playerCamera.position - otherPortal.position;
        transform.position = portal.position + playerOffsetFromPortal;

        float angularDifference = Quaternion.Angle(portal.rotation, otherPortal.rotation);

        Quaternion portalRotDiff = Quaternion.AngleAxis(angularDifference, Vector3.up);
        Vector3 newCameraDir = portalRotDiff * playerCamera.forward;
        transform.rotation = Quaternion.LookRotation(newCameraDir, Vector3.up);

        portalCam.nearClipPlane = Vector3.Distance(portalCam.transform.position, portal.position);

    }

}
