class UFONpcCow extends GGNpc;

function string GetActorName()
{
	return "Cow";
}

DefaultProperties
{
	ControllerClass=class'GGAIControllerCow'

	Begin Object name=CollisionCylinder
		CollisionRadius=32.0f
		CollisionHeight=140.0f
	End Object

	mStandUpDelay=1.5f
	mStandUpThresholdVel=400
	mAttackRange=600.0f
	mAttackMomentum=750.0f
	mTimesKnockedByGoatStayDownLimit=3

	Begin Object name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'MMO_Cow.Mesh.Cow_01'
		AnimSets(0)=AnimSet'MMO_Cow.Anim.Cow_Anim_01'
		AnimTreeTemplate=AnimTree'Characters.Anim.Characters_Animtree_01'
		PhysicsAsset=PhysicsAsset'MMO_Cow.Mesh.Cow_Physics_01'
		Translation=(Z=-140)
	End Object

	mDefaultAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)
	mDanceAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)
	mPanicAtWallAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)
	mPanicAnimationInfo=(AnimationNames=(Run),AnimationRate=1.0f,MovementSpeed=700.0f,LoopAnimation=true,SoundToPlay=())
	mAttackAnimationInfo=(AnimationNames=(Attack),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=false)
	mAngryAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true,SoundToPlay=())
	mIdleAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)
	mRunAnimationInfo=(AnimationNames=(Run),AnimationRate=1.0f,MovementSpeed=350.0f,LoopAnimation=true);
	mIdleSittingAnimationInfo=(AnimationNames=(Idle),AnimationRate=1.0f,MovementSpeed=0.0f,LoopAnimation=true)

	mKnockedOverSounds=(SoundCue'MMO_NPC_SND.Cue.NPC_Bear_Hurt_Cue')
}