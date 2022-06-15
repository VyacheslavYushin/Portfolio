Shader "Unlit/Cloud_Ter_Lava"
{
    Properties
    {
        _MaskTex ("Mask Texture", 2D) = "white" {}
        
        _RColor ("RChan Color", 2D) = "white" {}
        _GColor ("GChan Color", 2D) = "white" {}
        _BColor ("BChan color", 2D) = "white" {}

        _Emission ("Lava Emission", color) = (1,1,1,1)
        _Color ("Cloud color", color) = (1,1,1,1)
    }   
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float2 uv3 : TEXCOORD2;
                float2 uv4 : TEXCOORD3;
            };

            struct v2f
            {
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float2 uv3 : TEXCOORD2;
                float2 uv4 : TEXCOORD3;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _RColor;
            float4 _RColor_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            sampler2D _GColor;
            float4 _GColor_ST;
            sampler2D _BColor;
            float4 _BColor_ST;

            float4 _Emission;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1 = TRANSFORM_TEX(v.uv1, _MaskTex);
                o.uv2 = TRANSFORM_TEX(v.uv2, _RColor);
                o.uv3 = TRANSFORM_TEX(v.uv3, _GColor);
               // o.uv4 = TRANSFORM_TEX(v.uv4, _BColor);
                o.uv4 = TRANSFORM_TEX(v.uv4, _BColor);
                
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                
                float4 mask = tex2D(_MaskTex, i.uv1);
                fixed4 ter = tex2D(_RColor, i.uv2)* mask.r;
                fixed4 lava = tex2D(_GColor, i.uv3)* mask.g;
                fixed4 cloud = tex2D(_BColor, i.uv4) * mask.b;
                
               // cloud = saturate(cloud);
        
                
                //float cloud = tex2D

  
                 
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, ter);
                return ter + lava  + cloud ;
            }
            ENDCG
        }
    }
}
