Shader "Unlit/Shield"
{
    Properties
    {
        _LineTex ("Line texture", 2D) = "white" {}
        _ShieldTex ("Shield Textures", 2D) = "whire" {}
        _AdditionalDetailsTex ("Thunder texture", 2D) = "white" {}
        _ShielAmpl("Shield Amplitude", range(0, 1)) = 0.25
        _FresnelSTR("Fresnel Strainge", range(0,1)) = 1
        _ShieldMove("Shield Move", range(-1,1)) = 1
        _ThunderSTR("Thunder Strainge", range(0,1)) = 1
        
        _FresnelColor("Fresnel Color", color) = (1,1,1,1)
        _Color("First Color", color) = (1,1,1,1)
        _LineColor("Second color", color) = (1,1,1,1)

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
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
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD5;
                float2 uv2 : TEXCOORD6;
                float4 vertex : POSITION;
                float3 normal :NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD5;
                float2 uv2 : TEXCOORD6;
                float3 viewDir:TEXCOORD2;
                float4 fresnel : TEXCOORD3;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
                
            };

            sampler2D _LineTex, _ShieldTex , _AdditionalDetailsTex;
            float4 _LineTex_ST, _ShieldTex_ST,  _AdditionalDetailsTex_ST, _Color , _FresnelColor, _LineColor;
            
            float _FresnelSTR, _ShielAmpl, _ShieldMove, _ThunderSTR;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));

                o.uv = TRANSFORM_TEX(v.uv, _LineTex) + (_ShielAmpl * _Time.xz);
                o.uv1 = TRANSFORM_TEX(v.uv, _ShieldTex) + (_ShieldMove *  _Time.xz);
                o.uv2 = TRANSFORM_TEX(v.uv2, _AdditionalDetailsTex);

                //Fresnel
                o.fresnel = _FresnelSTR * (pow(saturate( 1- dot(o.worldNormal, o.viewDir)), 2.5 + sin(1.5 * _Time.y)));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Тextures
                fixed4 Line = tex2D(_LineTex, i.uv);
                fixed4 shield = tex2D(_ShieldTex, i.uv1);
                fixed4 thunder = tex2D(_AdditionalDetailsTex, i.uv2);

                //Shield
                shield = lerp(_Color, _LineColor, 0.5 + sin(1.5 *_Time.y));
                shield.a = tex2D(_ShieldTex, i.uv1).a; 
                Line*=  shield;

                //Color Fresnel
                fixed4 fresnelEnd = lerp(shield, _FresnelColor, i.fresnel);
                //fresnelEnd += _FresnelColor;

                //Thunder
                thunder = smoothstep (thunder, 0.45, 0.45) - smoothstep(thunder, 0.3 + (0.2 *  sin(4 *_Time.y)) , 0.4 + (0.2 *  sin(4 *_Time.y +1)));

                fixed4 end = (Line-shield) + fresnelEnd + (thunder * _ThunderSTR);

                return end;

            }
            ENDCG
        }
    }
}
