using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class Grass_Move : MonoBehaviour
{

    [SerializeField] private Material material;


    private Transform cachedTransform;
    private readonly int grassTrampleProperty = Shader.PropertyToID("_TrampleCoordinate");
    
    private void Awake()
    {
        cachedTransform = transform;
    }
 
    private void Update()
    {
        if (material == null)
        {
            return;
        }
 
        var position = cachedTransform.position;
        material.SetVector(grassTrampleProperty, new Vector4(position.x, position.y, position.z));
    }
}
