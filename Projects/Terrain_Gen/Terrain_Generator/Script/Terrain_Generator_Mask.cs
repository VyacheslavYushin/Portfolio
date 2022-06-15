// To save textures, you must specify the path
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer), typeof(MeshCollider))]
public class Terrain_Generator_Mask : MonoBehaviour
{

    Mesh mesh;
    Vector3[] vertices;

    public LayerMask mask = 256;
    int[] triangles;
    public Texture2D NoiseTex;
    public Texture2D MaskTex;

    public float NoiseStr = 1;
    public int ResolutionX = 10;
    public int ResolutionZ = 10;


    [Range (0,100)]
    public float Pwight = 1;
    [Range (0,100)]
    public float Phight = 1;
    public Shader _drawShader;

    
    private int px = 1;
    private int pz = 1;

    [Range (0,1)]
    public float Opacity = 1f;
    
    [Range (0,1)]
    public float BrushPow = 1f;

    public int BrushSize = 1;


    void Start()
    {
        mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;
        CreateShape();
        GetComponent<MeshCollider>().sharedMesh = mesh;
        GetComponent<MeshRenderer>().sharedMaterial = new Material(_drawShader);
  
    }
    void Update()
    { 
        CreateShape();
        if(Input.GetKey(KeyCode.X))
        {
            GetComponent<MeshCollider>().sharedMesh = mesh;
            Debug.Log("Mesh collider updated");
        }
        if(Input.GetKeyUp(KeyCode.F))
        {
            isTerrainPaint = !isTerrainPaint;
        }
        UptadeMesh(); 
        mesh.RecalculateNormals(); 
        mesh.RecalculateBounds();
    }

    void CreateShape()
    {    
        

        vertices = new Vector3[(ResolutionX + 1 ) * (ResolutionZ + 1) ];

        Vector2[] uvs = new Vector2[vertices.Length];

        for (int i = 0, z = 0; z <= ResolutionZ; z++)
        {
            for (int x = 0; x <= ResolutionX; x++, i++)
            {    
                float xFrac = (NoiseTex.width/(float)ResolutionZ * z)/(float)NoiseTex.width;
                float yFrac = (NoiseTex.height/(float)ResolutionX * x)/(float)NoiseTex.height;

                float y = NoiseTex.GetPixelBilinear(xFrac, yFrac).grayscale  * NoiseStr;
                vertices[i] = new Vector3 ((Pwight * x )/ ResolutionX,  y, (Phight * z)/ ResolutionZ );
                uvs[i] = new Vector2((float) z/ ResolutionZ, (float) x/ResolutionX); 
            }
        }
        mesh.vertices = vertices;

        mesh.uv = uvs;

        triangles = new int[ResolutionX * ResolutionZ * 6];

        for (int z = 0, vert = 0, tris = 0; z < ResolutionZ; z++, vert++)
        {
            for (int x = 0; x < ResolutionX; x++, tris += 6, vert++)
            {
                triangles[tris] = vert;
                triangles[tris + 1] = triangles[tris + 4] = vert + ResolutionX + 1;
                triangles[tris + 2] = triangles[tris + 3] = vert + 1;
                triangles[tris + 5] = vert + ResolutionX + 2;
            }

        }  

        mesh.triangles = triangles;   

    }

public bool isTerrainPaint = false;

//Raycast
    void UptadeMesh()
    {

        Color foregroundColor = new Color(BrushPow, BrushPow, BrushPow, BrushPow);
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        Debug.DrawRay(ray.origin, ray.direction * 211110, Color.blue);

        if(Physics.Raycast(ray, out hit,1000000,mask))
        {   
            if (Input.GetMouseButton(0))
            {
                if (isTerrainPaint)
                {
                   // Debug.Log(hit.point); 
                    var pixelCoords = uv2PixelCoords(hit.textureCoord,NoiseTex);
                    Stroke(pixelCoords, foregroundColor, NoiseTex);
                }
                else
                {
                    if (Input.GetKey(KeyCode.R))
                    {
                        var pixelCoords = uv2PixelCoords(hit.textureCoord,MaskTex);
                        Stroke(pixelCoords, Color.red,MaskTex);
                    }
                    if (Input.GetKey(KeyCode.G))
                    {
                        var pixelCoords = uv2PixelCoords(hit.textureCoord,MaskTex);
                        Stroke(pixelCoords, Color.green,MaskTex);
                    }
                    if (Input.GetKey(KeyCode.B))
                    {
                        var pixelCoords = uv2PixelCoords(hit.textureCoord,MaskTex);
                        Stroke(pixelCoords, Color.blue,MaskTex);
                    }
                }
            }
        }        
    }

    Vector2Int uv2PixelCoords(Vector2 uv, Texture2D tex) 
    {
        px = Mathf.FloorToInt(uv.x * tex.width);
        pz = Mathf.FloorToInt(uv.y * tex.height);
        return new Vector2Int(px,pz);
    }

//Draw
    void Stroke(Vector2Int pixelCoords, Color color, Texture2D tex)
    {
        if( BrushSize > 1)
        {

            int Sx = pixelCoords.x;
            int Sy = pixelCoords.y;
            
            for(int x = 0; x < BrushSize * 2; x++)
            {
                for(int y = 0; y < BrushSize * 2; y++)
                {
                    int OffsetX = x - BrushSize;
                    int OffsetY = y - BrushSize;

                    int finalX = Sx + OffsetX;
                    int finalY = Sy + OffsetY;

                    float distanceToCentre = Mathf.Sqrt((Sx-finalX)*(Sx-finalX) + (Sy - finalY)*(Sy - finalY));


                    if(distanceToCentre < BrushSize)
                    {
                        if(finalX >= 0 && finalX < tex.width && finalY >= 0 && finalY < tex.height)
                        {
                            Color oldCol = tex.GetPixel(finalX,finalY);
                            Color newCol = Color.Lerp(color, oldCol, distanceToCentre/BrushSize);
                            newCol = Color.Lerp(oldCol,newCol,Opacity); 
                            tex.SetPixel(finalX,finalY,newCol); 
                        }
                    }
                }
            }
        }      
        else
        {
            tex.SetPixel(px, pz, color);
        }

        tex.Apply();
    }


//Save
    /*void SaveTextureToFile(Texture2D textureSave, string path) 
    { 
        byte[] bytes = textureSave.EncodeToPNG();
        File.WriteAllBytes (path, bytes);
    }
    
    void OnApplicationQuit()
    {
        SaveTextureToFile(NoiseTex, @"...");
        SaveTextureToFile(MaskTex, @"...");

    }*/
}
