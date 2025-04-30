 #version 330
 in vec2 fragTexCoord;
 in vec4 fragColor;
 in vec3 fragNormal;
 in vec2 positionWS;


 
 uniform sampler2D texture0;
 uniform vec4 colDiffuse;
 
 out vec4 finalColor;


 void main()
 {
    // vec4 texelColor = texture(texture0, uv_klems(fragTexCoord,vec2(textureSize(texture0,0))));
	vec4 texelColor = texture2D(texture0, fragTexCoord);


	if( texelColor.a <= 0.0 )
	{
		discard;
	}
    finalColor = texelColor*colDiffuse*fragColor;
	// finalColor = vec4(positionWS.x/100,positionWS.y/100,0,1);



 }    