using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PortalTelep : MonoBehaviour
{
    public Transform player;
    public Transform reciever;
    private bool playaerIsOverlap = false;

    void Update()
    {
        if(playaerIsOverlap)
        {
            Vector3 portalToPlayer = player.position - transform.position;
            float dotProduct = Vector3.Dot(transform.up, portalToPlayer);

            if (dotProduct < 0f)
            {
                float rotationDiff = -Quaternion.Angle(transform.rotation, reciever.rotation);
                rotationDiff += 180;
                player.Rotate(Vector3.down, rotationDiff);

                Vector3 positionOffsset = Quaternion.Euler(0f, rotationDiff, 0f) * portalToPlayer;
                player.position = reciever.position + positionOffsset;

                playaerIsOverlap = false;
            }
        }
    }

    void OnTriggerEnter(Collider other) 
    {
        if (other.tag == "Player")
        {
            playaerIsOverlap = true;   
        }
    }
    void OnTriggerExit(Collider other) 
    {
    if (other.tag == "Player")
        {
            playaerIsOverlap = false;   
        }     
    }
    
}
