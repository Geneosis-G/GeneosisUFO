class UFONpcTRex extends GGNpc;

function string GetActorName()
{
	return "T-Rex";
}

DefaultProperties
{
	ControllerClass=class'GGAIControllerOldGoat'

	Begin Object name=CollisionCylinder
		CollisionRadius=200.0f
		CollisionHeight=250.0f
	End Object

	mStandUpDelay=0.5f
	mStandUpThresholdVel=400
	mAttackRange=1250.0f
	mAttackMomentum=1000.0f
	mTimesKnockedByGoatStayDownLimit=3

	Begin Object name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'MMO_OldGoat.mesh.OldGoat_01'
		AnimSets(0)=AnimSet'MMO_OldGoat.Anim.OldGoat_Anim_01'
		AnimTreeTemplate=AnimTree'MMO_OldGoat.Anim.OldGoat_AnimTree'
		PhysicsAsset=PhysicsAsset'MMO_OldGoat.Mesh.OldGoat_Physics_01'
		Translation=(Z=20)
	End Object

	mDefaultAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=300.0f,LoopAnimation=true)
	mDanceAnimationInfo=(AnimationNames=(Idle_02),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)
	mPanicAtWallAnimationInfo=(AnimationNames=(Idle_01),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)
	mPanicAnimationInfo=(AnimationNames=(Sprint_01, Sprint_02),AnimationRate=1.0f,MovementSpeed=700.0f,LoopAnimation=true,SoundToPlay=())
	mAttackAnimationInfo=(AnimationNames=(Ram),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=false)
	mAngryAnimationInfo=(AnimationNames=(Idle_01,Idle_02,Baa),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true,SoundToPlay=())
	mIdleAnimationInfo=(AnimationNames=(Idle_01,Idle_02),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)
	mRunAnimationInfo=(AnimationNames=(Run_01),AnimationRate=1.0f,MovementSpeed=700.0f,LoopAnimation=true);
	mIdleSittingAnimationInfo=(AnimationNames=(Idle_01),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)

	mKnockedOverSounds=(SoundCue'MMO_NPC_SND.Cue.NPC_T-Rex_Hurt_Cue')
}