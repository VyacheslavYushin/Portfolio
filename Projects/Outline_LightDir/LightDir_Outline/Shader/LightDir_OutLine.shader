Shader "Custom/Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _OutlineColor ("Outline Colour", Color) = (0,0,0,1)
        _OutlineThickness ("Outline Thickness", Range(0,1)) = 0.0

        _BackLightColor("Back Light Colour", Color) = (0.5,0.5,0.5,1)
        _BackLightDir("Back Light Direction", Range(-1,1))= 0.0
        _BackLightFor( "Back Light Force", Range(0,1)) = 0.0


    }
    SubShader
    {
        Tags {"RenderType"="Opaque" "Queue"="Transparent+1" "LightMode"="ForwardBase"}       
         Pass
        {
            Cull Front
            Zwrite Off
            CGPROGRAM

            #pragma vertex vert 
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
            };

            fixed4 _OutlineColor;
            float _OutlineThickness;

            v2f vert (appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex + normalize(v.normal) * _OutlineThickness);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }

            ENDCG
        }

        Pass
        {

            Zwrite on

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            #include "Lighting.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD2;


            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD2;
                float4 position : SV_POSITION;
                fixed4 light : COLOR0;
                float3 worldNormal : NORMAL;
                

            };

            sampler2D _MainTex;

            float4 _MainTex_ST;
            float4 _BackLightColor;
            float _BackLightDir;
            fixed _BackLightFor;
            float4 _FrontLightColor;

            float3 Unity_RotateAboutAxis_Degrees_float(float3 In, float3 Axis, float Rotation)
            {
                Rotation = radians(Rotation);
                float s = sin(Rotation);
                float c = cos(Rotation);
                float one_minus_c = 1.0 - c;

                Axis = normalize(Axis);
                float3x3 rot_mat = 
                {   one_minus_c * Axis.x * Axis.x + c, one_minus_c * Axis.x * Axis.y - Axis.z * s, one_minus_c * Axis.z * Axis.x + Axis.y * s,
                    one_minus_c * Axis.x * Axis.y + Axis.z * s, one_minus_c * Axis.y * Axis.y + c, one_minus_c * Axis.y * Axis.z - Axis.x * s,
                    one_minus_c * Axis.z * Axis.x - Axis.y * s, one_minus_c * Axis.y * Axis.z + Axis.x * s, one_minus_c * Axis.z * Axis.z + c
                };
                return mul(rot_mat,  In);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.viewDir = Unity_RotateAboutAxis_Degrees_float(WorldSpaceViewDir(v.vertex), float3(0,1,0),_BackLightDir * 90);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(i.viewDir);

                float Ndotl = dot(_WorldSpaceLightPos0, normal);
                float4 fcolor = Ndotl * _LightColor0;
                
                float rimLight = _BackLightFor * pow( 1 - dot(viewDir, normal), 10);
                float4 bcolor = rimLight *  (_BackLightColor);

                return col * fcolor + bcolor;

            }
            ENDCG
        }  
       
     }
}
