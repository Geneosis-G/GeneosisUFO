class UFOAsteroid extends GGKactor
	placeable;

function string GetActorName()
{
	return "Asteroid";
}

DefaultProperties
{
	Begin Object name=StaticMeshComponent0
		StaticMesh=StaticMesh'Goat_Environment_01.mesh.Rock_Big_03'
	End Object

	bStatic=false
	bNoDelete=false
}