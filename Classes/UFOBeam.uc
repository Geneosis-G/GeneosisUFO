class UFOBeam extends DynamicSMActor;

var ParticleSystemComponent beamEffect;

DefaultProperties
{
	Begin Object name=StaticMeshComponent0
		StaticMesh=StaticMesh'Goat_Effects.Mesh.Lightbeam_01'
		Materials(0)=MaterialInstanceConstant'Goat_Effects.Materials.UFO_LightBeam_01'
		CollideActors=false
		Scale3D=(X=25,Y=25,Z=80)
	End Object

	CollisionType=COLLIDE_NoCollision
	CollisionComponent=StaticMeshComponent0

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
        Template=ParticleSystem'Goat_Effects.Effects.Effects_Smoke_02'
        Rotation=(Pitch=7168,Yaw=-32768,Roll=-32768)
		bAutoActivate=true
		Translation=(X=0,Y=0,Z=-5000)
	End Object
	beamEffect=ParticleSystemComponent0
	Components.Add(ParticleSystemComponent0)

	bNoDelete=false
	bStatic=false
}