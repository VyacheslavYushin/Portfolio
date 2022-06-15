Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _GrassTex ("Grass Texture", 2D) = "white" {}
        [Header(Wind)]
        _windTimeMult ("Wind Frequency", float) = 1
        _windAmplitude ("Wind Amplitude", range(0,1)) = 0.1
        _WindSpeed ("Wind Speed", range(0,1)) = 0
        [Header(Trample)]
        _TrampleCoordinate("Trample", Vector) = (0, 0, 0, 0)
        _TrampleStrength("Trample Strength", Range(0, 5)) = 0.2
        _TrampleRadius ("Trample Radius", Range(0, 3)) = 1

        _Impactlevel("Impact level", range(0,1)) = 0.1

        
    
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        Cull off
        Zwrite off
        Blend SrcAlpha OneMinusSrcAlpha



        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 worldSpacePos : TEXCOORD1;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldSpacePos : TEXCOORD1;
                fixed4 color : COLOR;
            };

            sampler2D _GrassTex;
            float4 _GrassTex_ST;
            float _windTimeMult; //Скорость
            float _windAmplitude; //Амплитуда
            float _WindSpeed; //Скорость
            float4 _TrampleCoordinate; //Координаты Player
            float _TrampleStrength; //Сила прижатия
            float _TrampleRadius; //Радиус воздействия Player

            float _Impactlevel;// Уровень воздействия

            float3 UnityObjectToWorldPos(float3 LocalPos)
            {
                return mul( unity_ObjectToWorld, float4( LocalPos, 1 ) ).xyz;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _GrassTex);
                o.color = v.color;
                float3 worldSpacePos = UnityObjectToWorldPos(v.vertex);
                worldSpacePos *= v.color.g;
                
                //Прижатие
                float3 delta = worldSpacePos - _TrampleCoordinate.xyz;
                float affection = (1 - saturate(length(delta)/_TrampleRadius)) * _TrampleStrength;
                float3 trampleDirection = normalize(delta) * affection;
                float heigh = 0.05;
                trampleDirection.y = lerp((-1 * affection * _TrampleRadius), heigh, _Impactlevel);
                //trampleDirection.y = -1 * affection * _TrampleRadius;
                o.vertex += mul(UNITY_MATRIX_VP, trampleDirection);
                
                //Ветер
                o.vertex.x += sin ((o.uv - (_Time.y * _WindSpeed)) * _windTimeMult) * (o.uv.y * _windAmplitude);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_GrassTex, i.uv);
                return color;
            }
        ENDCG
        }
    }
}