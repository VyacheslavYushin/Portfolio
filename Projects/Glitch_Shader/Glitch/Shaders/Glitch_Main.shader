Shader "Unlit/Glitch_Main"
{
    Properties
    {
        _MainTexture ("Main Texture", 2D) = "white" {}
        _DisplacementTexture("Displacement Texture", 2D) = "white" {}
        _MaskTexture ("Mask Texture", 2D) = "white" {}
        _DisplacementDirection("Displacement Direction", vector) = (0, 0, 0, 0)
        _RandomizeTime ("Randomize time", range(0,0.5)) = 0
        _GlitchFrequency ("Frequency over time", float) = 0
        _ShiftAberretionX("_Shift Aberretion X", float) = 0
        _ShiftAberretionY("_Shift Aberretion Y", float) = 0
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
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
                float2 glitch : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 glitch : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float2 abberationDisplacement : TEXCOORD4;
                float2 randomValue : TEXCOORD5;
            };

            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            sampler2D _DisplacementTexture;
            float4 _DisplacementTexture_ST;
            sampler2D _MaskTexture;
            float4 _MaskTexture_ST;

            fixed4 _DisplacementDirection;
            float _ShiftAberretionX;
            float _ShiftAberretionY;
            float _RandomizeTime;
            float _GlitchFrequency;

            float rand(float2 co)
            {
                return frac(sin( dot(co ,float2(12.9898,78.233))) * 43758.5453 );
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                o.glitch = TRANSFORM_TEX(v.glitch, _DisplacementTexture);
                o.abberationDisplacement = fixed2(_ShiftAberretionX, _ShiftAberretionY);
                o.randomValue = (rand(_Time.y) -0.5) * 2;
                return o;
            }

            float2 Aberration = fixed4(0, 0, 0, 0);
            float2 DisplacementValue = fixed2(0, 0);

            fixed4 frag (v2f i) : SV_Target
            {
                float4 glitchTexture = tex2D(_DisplacementTexture, i.glitch);
                float glitchLerpFactor = frac(i.randomValue);          
                float2 abberationDisplacement = i.abberationDisplacement;
                float TimeModifier = frac(glitchLerpFactor *_RandomizeTime + _Time.y * _GlitchFrequency);
                float EnableTimeDisplacement = max( 0 ,TimeModifier - 0.5);

                //Enable Glitch
                DisplacementValue = lerp(0, glitchTexture.xy * _DisplacementDirection.xy, glitchLerpFactor) * EnableTimeDisplacement;  

                //Abberation
                Aberration = lerp(0, abberationDisplacement.xy, glitchLerpFactor) * EnableTimeDisplacement;
                
                //Abberation + Color
                fixed4 ColGAndA = tex2D(_MainTexture, i.uv + DisplacementValue);
                fixed ColorR = tex2D(_MainTexture, i.uv + DisplacementValue + Aberration).r;
                fixed ColorG = ColGAndA.g;
                fixed ColorB = tex2D(_MainTexture, i.uv + DisplacementValue - Aberration).b;
                fixed ColorA = ColGAndA.a * tex2D(_MaskTexture, i.uv + DisplacementValue).r;            
                fixed4 finalColor = fixed4(ColorR, ColorG, ColorB, ColorA);

                return finalColor;
            }
        ENDCG
        }
    }
}