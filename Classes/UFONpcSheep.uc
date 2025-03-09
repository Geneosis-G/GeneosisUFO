class UFONpcSheep extends GGNpc;

function string GetActorName()
{
	return "Sheep";
}

DefaultProperties
{
	ControllerClass=class'GGAIControllerSheep'

	Begin Object name=CollisionCylinder
		CollisionRadius=25.0f
		CollisionHeight=30.0f
		CollideActors=true
		BlockActors=true
		BlockRigidBody=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
	End Object

	mStandUpDelay=0.5f
	mStandUpThresholdVel=400
	mAttackRange=200.0f
	mAttackMomentum=650.0f
	mTimesKnockedByGoatStayDownLimit=5

	Begin Object name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'MMO_Sheep.Mesh.Sheep_01'
		AnimSets(0)=AnimSet'goat.Anim.Goat_Anim_01'
		AnimTreeTemplate=AnimTree'goat.Anim.Goat_AnimTree'
		PhysicsAsset=PhysicsAsset'goat.Mesh.goat_Physics'
		Translation=(Z=0)
	End Object

	mDefaultAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=250.0f,LoopAnimation=true,SoundToPlay=())
	mDanceAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)
	mPanicAtWallAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true,SoundToPlay=())
	mPanicAnimationInfo=(AnimationNames=(Sprint_01, Sprint_02),AnimationRate=1.0f,MovementSpeed=700.0f,LoopAnimation=true,SoundToPlay=())
	mAttackAnimationInfo=(AnimationNames=(Ram),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=false,SoundToPlay=())
	mAngryAnimationInfo=(AnimationNames=(Idle,Idle,Baa),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true,SoundToPlay=())
	mIdleAnimationInfo=(AnimationNames=(Idle,Idle),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true,SoundToPlay=())
	mApplaudAnimationInfo=(AnimationNames=(Idle,Idle,Baa,Baa),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=false,SoundToPlay=())
	mRunAnimationInfo=(AnimationNames=(Run),AnimationRate=1.0f,MovementSpeed=700.0f,LoopAnimation=true,SoundToPlay=());
	mIdleSittingAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)

	mKnockedOverSounds=(SoundCue'MMO_NPC_SND.Cue.NPC_Sheep_Speech_Cue')
}