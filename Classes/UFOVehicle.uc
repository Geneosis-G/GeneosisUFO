class UFOVehicle extends GGSVehicle
	placeable;

/** The name displayed in a combo */
var string mScoreActorName;

/** The maximum score this longboard is worth interacting with in a combo */
var int mScore;

var float mJumpForceSize;

var GGGoat UFOowner;
// for some reasons those values are only valid if you read them in the mutator Tick
var float currentBaseY;
var float currentStrafe;


var int keypressedcount;
var bool goUp;
var bool goDown;
var bool forwardPressed;
var bool backPressed;
var bool leftPressed;
var bool rightPressed;
var bool isMoving;

var rotator initRotation;
var rotator expectedRotation;
var vector expectedPosition;
var float spinRate;

var bool isOpening;
var bool isClosing;
var bool isBeamActive;
var bool shouldOpen;
var float mOpenCloseAnimTime;
var UFOBeam mBeam;
var float attractionForce;
var float beamHeight;
var float beamRadius;
var float mVehicleCheckRadius;
var array<Actor> mBeamedActors;

var float holdRange;
var UFOHold mHold;
var GGHUDGfxIngame mHUD;
var bool shouldPopulate;
var float lastSelectedIndex;

var StaticMeshComponent alienHead;
var int test;
var array<Material> goatMaterials;

var SoundCue mBeamEndSoundCue;
var SoundCue mBeamStartSoundCue;

var Soundcue mSaucerBeepSoundCue;
var SoundCue mSuacerLoopSoundCue;

var AudioComponent mAudioComponentLoop;
var AudioComponent mAudioComponentBeep;
var AudioComponent mAudioComponentBeam;

simulated event PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();
	// Not working :/
	//EnableFullPerPolyCollision();

	mAudioComponentBeep = CreateAudioComponent( mSaucerBeepSoundCue );
	mAudioComponentBeep.Play();

	mAudioComponentLoop = CreateAudioComponent( mSuacerLoopSoundCue );
	mAudioComponentLoop.Play();

	for( i = 0; i < mNumberOfSeats; i++ )
	{
		// Remove normal seats
		mPassengerSeats[i].VehiclePassengerSeat.ShutDown();
		mPassengerSeats[i].VehiclePassengerSeat.Destroy();
		// Add custom seats
		mPassengerSeats[i].VehiclePassengerSeat = Spawn( class'UFOSeat' );
		mPassengerSeats[i].VehiclePassengerSeat.SetBase( self );
		mPassengerSeats[i].VehiclePassengerSeat.mVehicleOwner = self;
		mPassengerSeats[i].VehiclePassengerSeat.mVehicleSeatIndex = i;
	}

	InitUFO(GGGoat(Owner));
}

function EnableFullPerPolyCollision()
{
	local array<name> boneNames;
	local name boneName;
	local SkeletalMesh oldSkel;

	oldSkel=mesh.SkeletalMesh;
	oldSkel.PerPolyCollisionBones.Length=0;
	mesh.GetBoneNames(boneNames);
	foreach boneNames(boneName)
	{
		oldSkel.PerPolyCollisionBones.AddItem(boneName);
	}
	oldSkel.bUseSimpleBoxCollision=false;
	oldSkel.bUseSimpleLineCollision=false;
	mesh.SetSkeletalMesh(none);
	mesh.SetSkeletalMesh(oldSkel);
}

function InitUFO(GGGoat UFO_owner)
{
	local RB_BodyInstance bodyInst;

	UFOowner=UFO_owner;
	CollisionComponent=mesh;

	expectedRotation=initRotation;

	// Fix mass
    mesh.PhysicsAsset.BodySetup[0].MassScale = 1000000.f;
    bodyInst = mesh.GetRootBodyInstance();
    bodyInst.UpdateMassProperties(mesh.PhysicsAsset.BodySetup[0]);
	// Create beam effect
    mBeam=Spawn(class'UFOBeam');
    mBeam.SetBase(self);
    mBeam.SetHidden(true);
    // Create inventory
    mHold = Spawn( class'UFOHold', self );
	mHold.InitiateInventory();

	OpenCloseUFO();

	AddEasterEgg();

    mesh.WakeRigidBody();
}

simulated event Tick( float deltaTime )
{
	local vector camLocation, desiredDirection2D, desiredBoostDirection;
	local rotator camRotation;

	super.Tick( deltaTime );
	isMoving=false;
	//Stop if not moving
	if(bDriving)
	{
		if(mHUD.mInventoryOpen)
		{
			lastSelectedIndex=mHUD.mInventory.GetFloat( "selectedIndex" );
			//WorldInfo.Game.Broadcast(self, "lastSelectedIndex=" $ lastSelectedIndex);
			if(shouldPopulate)
			{
				PopulateInventory();
			}
			LockPosition();
		}
		else // Move only if inventory closed
		{
			// Manage movements
			if(goUp)
			{
				AddImpulse( vect(0, 0, 1) * 2 * mJumpForceSize * deltaTime );
				isMoving=true;
			}
			if(goDown)
			{
				AddImpulse( vect(0, 0, -1) * mJumpForceSize * deltaTime );
				isMoving=true;
			}

			if(GGLocalPlayer(PlayerController( Controller ).Player).mIsUsingGamePad)
			{
				if(abs(currentBaseY) > 0.2f)
				{
					desiredDirection2D.X=currentBaseY;
				}
				if(abs(currentStrafe) > 0.2f)
				{
					desiredDirection2D.Y=currentStrafe;
				}
				if(IsZero(desiredDirection2D) && keypressedcount == 0)
				{
					LockPosition();
				}
				else
				{
					expectedPosition=vect(0, 0, 0);
				}
			}
			else
			{
				if(forwardPressed)
				{
					desiredDirection2D.X += 1.f;
				}
				if(backPressed)
				{
					desiredDirection2D.X += -1.f;
				}
				if(leftPressed)
				{
					desiredDirection2D.Y += -1.f;
				}
				if(rightPressed)
				{
					desiredDirection2D.Y += 1.f;
				}
				if(keypressedcount == 0)
				{
					LockPosition();
				}
				else
				{
					expectedPosition=vect(0, 0, 0);
				}
			}
			desiredDirection2D=Normal(desiredDirection2D);
			GGPlayerControllerGame( Controller ).PlayerCamera.GetCameraViewPoint( camLocation, camRotation );
			desiredBoostDirection = Vector(camRotation);
			if(!IsZero(desiredDirection2D))
			{
				desiredBoostDirection.Z=0;
				desiredBoostDirection=desiredDirection2D >> Rotator(desiredBoostDirection);
			}
			if(!IsZero(desiredBoostDirection))
			{
				AddImpulse( vect(0, 0, 1) * mJumpForceSize * deltaTime );
				AddImpulse( desiredBoostDirection * mJumpForceSize * deltaTime );
				isMoving=true;
			}
			//WorldInfo.Game.Broadcast(self, "Rotation=" $ Rotation);
			//WorldInfo.Game.Broadcast(self, "RBRotation=" $ mesh.GetRotation());
		}
	}
	else
	{
		LockPosition();
	}

	// Force rotation
	expectedRotation.Yaw=expectedRotation.Yaw + deltaTime * spinRate;
	mesh.SetRBRotation(expectedRotation);

	BeamAttractionEffect(deltaTime);

	UpdateBlockCamera();

	SetTireSound();
	//WorldInfo.Game.Broadcast(self, "Location=" $ mBeamVolume.Location $ "/" $ Location);
}

function LockPosition()
{
	if(IsZero(expectedPosition))
	{
		expectedPosition=mesh.GetPosition();
	}
	mesh.SetRBLinearVelocity(vect(0, 0, 0));
	mesh.SetRBPosition(expectedPosition);
}

function ModifyCameraZoom( PlayerController contr, optional bool exit, optional bool passenger)
{
	local GGCameraModeVehicle orbitalCamera;
	local GGCamera.ECameraMode camMode;

	camMode=passenger?3:2;//Haxx because for some reason calling CM_Vehicle and CM_Vehicle_Passenger no longer works
	orbitalCamera = GGCameraModeVehicle( GGCamera( contr.PlayerCamera ).mCameraModes[ camMode ] );
	//WorldInfo.Game.Broadcast(self, "contr=" $ contr $ ", exit=" $ exit $ ", passenger=" $ passenger $ ", orbitalCamera=" $ orbitalCamera);
	if(exit)
	{
		orbitalCamera.mMaxZoomDistance = orbitalCamera.default.mMaxZoomDistance;
		orbitalCamera.mMinZoomDistance = orbitalCamera.default.mMinZoomDistance;
		orbitalCamera.mDesiredZoomDistance = orbitalCamera.default.mDesiredZoomDistance;
		orbitalCamera.mCurrentZoomDistance = orbitalCamera.default.mCurrentZoomDistance;
	}
	else
	{
		orbitalCamera.mMaxZoomDistance = 10000;
		orbitalCamera.mMinZoomDistance = 1500;
		orbitalCamera.mDesiredZoomDistance = CamDist;
		orbitalCamera.mCurrentZoomDistance = CamDist;
	}
}

function UpdateBlockCamera()
{
	local bool shouldBlockCamera;
	local int i;

	shouldBlockCamera=true;
	if(bDriving)
	{
		shouldBlockCamera=false;
	}
	else
	{
		for( i = 0; i < mPassengerSeats.Length; i++ )
		{
			if( mPassengerSeats[ i ].PassengerPawn != none )
			{
				shouldBlockCamera=false;
				break;
			}
		}
	}
	mBlockCamera=shouldBlockCamera;
}

/**
 * Display hud tip for how to drive.
 */
function DisplayHUDTip( optional bool forceRemove = false )
{
	local int i;
	local GGPlayerControllerGame gameController;
	local float distToPlayer;
	local Engine engine;

	engine = class'Engine'.static.GetEngine();

	for( i = 0; i < engine.GamePlayers.Length; i++ )
	{
		gameController = GGPlayerControllerGame( engine.GamePlayers[ i ].Actor );

		if( gameController == none || gameController.Pawn == none )
		{
			continue;
		}

		if( forceRemove )
		{
			mHintLabelActive = !gameController.RemoveHintLabelMessage( "VEHICLE" );
			return;
		}

		distToPlayer = VSize( gameController.Pawn.Location - Location );

		if( mVehicleCheckRadius >= distToPlayer && GGGoat(gameController.Pawn) != None && AnySeatAvailable() )
		{
			gameController.AddHintLabelMessage( "VEHICLE", USE_KEY_STRING @ mUseString, 6 );
			mHintLabelActive = true;
		}
		else if( mHintLabelActive )
		{
			mHintLabelActive = !gameController.RemoveHintLabelMessage( "VEHICLE" );
		}
	}
}

/**
 * See super.
 */
function GetInVechile( Pawn userPawn )
{
	super.GetInVechile( userPawn );

	mBeam.beamEffect.SetHidden(true);
	OpenCloseUFO();
}

/**
 * See super.
 *
 * Overridden to register a key listener for input
 */
function bool DriverEnter( Pawn userPawn )
{
	local bool driverCouldEnter;

	driverCouldEnter = super.DriverEnter( userPawn );

	if( driverCouldEnter )
	{
		//ModifyCameraZoom(PlayerController(Controller));

		mHUD=GGHUD( GGPlayerControllerGame(Controller).myHUD ).mHUDMovie;
		if(mHUD.mInventory == none)
		{
			mHUD.AddInventory();
			mHUD.mInventory.Setup();
			mHUD.ShowInventory( false );
			mHUD.mInventoryDescription.Setup();
			mHUD.SetInventoryDescription();
		}
		mHUD.mInventory.OnItemClick=OnInventoryItemClicked;
	}

	return driverCouldEnter;
}

/**
 * Take care of the new passenger
 */
function bool PassengerEnter( Pawn userPawn )
{
	local bool driverCouldEnter;

	driverCouldEnter = super.PassengerEnter( userPawn );

	if( driverCouldEnter )
	{
		//WorldInfo.Game.Broadcast(self, "PassengerEnter=" $ userPawn.DrivenVehicle.Controller);
		//ModifyCameraZoom(PlayerController(userPawn.DrivenVehicle.Controller), false, true);
	}

	return driverCouldEnter;
}

/**
 * See super.
 */
function GetOutOfVehicle( Pawn userPawn )
{
	super.GetOutOfVehicle( userPawn );

	goUp=false;
	goDown=false;
	keypressedcount=0;
	expectedPosition=mesh.GetPosition();
	mBeam.beamEffect.SetHidden(false);
	//ModifyCameraZoom(PlayerController(userPawn.Controller), true);
	if(mHold.mOpen)
	{
		ToggleInventory(userPawn.Controller);
	}
	mHUD.mInventory.OnItemClick=mHUD.OnInventoryItemClicked;
	if(isClosing)
	{
		shouldOpen=true;
	}
	else if(!isBeamActive)
	{
		OpenCloseUFO();
	}
}

function PassengerLeave( int seatIndex )
{
	//ModifyCameraZoom(PlayerController(mPassengerSeats[ seatIndex ].PassengerPawn.Controller), true, true);
	//WorldInfo.Game.Broadcast(self, "PassengerLeave=" $ mPassengerSeats[ seatIndex ].PassengerPawn.Controller);
	super.PassengerLeave(seatIndex);
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	local GGPlayerInputGame localInput;
	local bool isMovementKeyPressed;

	super.KeyState(newKey, keyState, PCOwner);

	if(PCOwner != Controller || !ShouldListenToDriverInput())
		return;

	localInput = GGPlayerInputGame( PCOwner.PlayerInput );

	if( keyState == KS_Down )
	{
		// Check which key it is and then decide what to do.
		localInput = GGPlayerInputGame( PlayerController( Controller ).PlayerInput );
		isMovementKeyPressed=true;
		if( localInput.IsKeyIsPressed( "GBA_Jump", string( newKey ) ) )
		{
			goUp=true;
		}
		else if( localInput.IsKeyIsPressed( "GBA_ToggleRagdoll", string( newKey ) ) )
		{
			goDown=true;
		}
		else if(localInput.IsKeyIsPressed("GBA_Forward", string( newKey )))
		{
			forwardPressed=true;
		}
		else if(localInput.IsKeyIsPressed("GBA_Back", string( newKey )))
		{
			backPressed=true;
		}
		else if(localInput.IsKeyIsPressed("GBA_Left", string( newKey )))
		{
			leftPressed=true;
		}
		else if(localInput.IsKeyIsPressed("GBA_Right", string( newKey )))
		{
			rightPressed=true;
		}
		else
		{
			isMovementKeyPressed=false;
			if( localInput.IsKeyIsPressed( "GBA_AbilityBite", string( newKey ) ) )
			{
				OpenCloseUFO();
			}
			else if( localInput.IsKeyIsPressed( "GBA_ToggleInventory", string( newKey ) ) )
			{
				ToggleInventory(Controller);
			}
			else if( localInput.IsKeyIsPressed( "GBA_Baa", string( newKey ) ) )
			{
				if( mHUD.mInventoryOpen )
				{
					RemoveFromInventory( lastSelectedIndex );
				}
				else
				{
					mHold.RemoveFromInventory(0);
				}
			}
			else if( newKey == 'Escape' || newKey == 'XboxTypeS_Start')
			{
				if( mHUD.mInventoryOpen )
				{
					ToggleInventory(Controller);
				}
			}
			//WorldInfo.Game.Broadcast(self, "newKey=" $ newKey);
		}
		/*if(newKey == 'P')
		{
			AddEasterEgg(test);
		}
		if(newKey == 'M')
		{
			test++;
			if(test==11)
				test=0;
		}*/

		if(isMovementKeyPressed)
		{
			keypressedcount++;
		}
	}
	else if( keyState == KS_Up )
	{
		// Check which key it is and then decide what to do.
		localInput = GGPlayerInputGame( PlayerController( Controller ).PlayerInput );
		isMovementKeyPressed=true;
		if( localInput.IsKeyIsPressed( "GBA_Jump", string( newKey ) ) )
		{
			goUp=false;
		}
		else if( localInput.IsKeyIsPressed( "GBA_ToggleRagdoll", string( newKey ) ) )
		{
			goDown=false;
		}
		else if(localInput.IsKeyIsPressed("GBA_Forward", string( newKey )))
		{
			forwardPressed=false;
		}
		else if(localInput.IsKeyIsPressed("GBA_Back", string( newKey )))
		{
			backPressed=false;
		}
		else if(localInput.IsKeyIsPressed("GBA_Left", string( newKey )))
		{
			leftPressed=false;
		}
		else if(localInput.IsKeyIsPressed("GBA_Right", string( newKey )))
		{
			rightPressed=false;
		}
		else
		{
			isMovementKeyPressed=false;
		}

		if(isMovementKeyPressed)
		{
			keypressedcount--;
			if(keypressedcount<0)
				keypressedcount=0;
		}
	}
}

function OpenCloseUFO()
{
	if(isOpening || isClosing)
		return;

	if(isBeamActive)
	{
		isClosing=true;
		isBeamActive=false;
		mBeam.SetHidden(true);
		SetTimer(mOpenCloseAnimTime, false, NameOf( UFOClosed ));
	}
	else
	{
		isOpening=true;
		SetTimer(mOpenCloseAnimTime, false, NameOf( UFOOpened ));
	}
	ManageAnim();
}

function UFOOpened()
{
	isOpening=false;
	isBeamActive=true;
	mBeam.SetHidden(false);
	ManageAnim();
	ManageSound(true);
}

function UFOClosed()
{
	isClosing=false;
	ManageAnim();
	ManageSound(false);
	if(shouldOpen)
	{
		shouldOpen=false;
		OpenCloseUFO();
	}
}

function ManageAnim()
{
	if(isOpening)
	{
		mesh.PlayAnim('Open');
	}
	else if(isClosing)
	{
		mesh.PlayAnim('Open',,,,, true);
	}
	else if(isBeamActive)
	{
		mesh.PlayAnim('OpenIdle',, true);
	}
	else
	{
		mesh.PlayAnim('Idle',, true);
	}
}

function ManageSound(bool shouldPlay)
{
	if(shouldPlay)
	{
		if( mAudioComponentBeam == none )
		{
			mAudioComponentBeam = CreateAudioComponent( mBeamStartSoundCue );
		}
		else
		{
			mAudioComponentBeam.Stop();
			mAudioComponentBeam.SoundCue = mBeamStartSoundCue;
		}
		mAudioComponentBeam.Play();
	}
	else
	{
		mAudioComponentBeam.Stop();
		mAudioComponentBeam.SoundCue = mBeamEndSoundCue;
		mAudioComponentBeam.Play();
	}
}

function BeamAttractionEffect(float deltaTime)
{
	local Actor attrActor;
	local GGPawn attrPawn;
	local GGKActor attrKact;
	local GGSVehicle attrVehicle;
	local vector vel, attrPos;
	local PrimitiveComponent attrComp;
	local float r, h;

	if(!isBeamActive)
	{
		mBeamedActors.Length=0;
		return;
	}

	GetTouchingActors();
	if(bDriving)
	{
		foreach mBeamedActors(attrActor)
		{
			attrPawn=GGPawn(attrActor);
			attrKact=GGKActor(attrActor);
			attrVehicle=GGSVehicle(attrActor);

			if(attrPawn != none)
			{
				if(attrPawn.mIsRagdoll)
				{
					attrComp=attrPawn.mesh;
				}
				else
				{
					attrPawn.SetPhysics(PHYS_Falling);
					attrPawn.Velocity.Z=attractionForce;
					attrPos=attrPawn.Location;
				}
			}
			else if(attrKact != none)
			{
				attrComp=attrKact.StaticMeshComponent;
			}
			else if(attrVehicle != none)
			{
				attrComp=attrVehicle.mesh;
			}

			if(attrComp != none)
			{
				vel=attrComp.GetRBLinearVelocity();
				vel.Z=attractionForce;
				attrComp.SetRBLinearVelocity(vel);
				attrPos=attrComp.GetPosition();
			}
			// Add close enough items to the hold/seats
			//WorldInfo.Game.Broadcast(self, attrActor $ " dist=" $ VSize(attrPos - Location));
			attrActor.GetBoundingCylinder(r, h);
			if(VSize(attrPos - Location) < holdRange + sqrt(r*r + h*h))
			{
				//WorldInfo.Game.Broadcast(self, attrActor $ " added to hold");
				AddItemToHold(attrActor);
			}
		}
	}
	else
	{
		foreach mBeamedActors(attrActor)
		{
			attrPawn=GGPawn(attrActor);
			if(attrPawn != none)
			{
				if(attrPawn == UFOOwner && (attrPawn.Physics == PHYS_Falling || attrPawn.Physics == PHYS_Flying))
				{
					attrPawn.Velocity.Z = attrPawn.Velocity.Z<0?-attractionForce:attractionForce;
				}
				// Add close enough pawn to the driver seat
				attrPos=attrPawn.mesh.GetPosition();
				attrActor.GetBoundingCylinder(r, h);
				if(VSize(attrPos - Location) < holdRange + sqrt(r*r + h*h))
				{
					//WorldInfo.Game.Broadcast(self, attrActor $ " added to hold");
					AddItemToHold(attrActor);
				}
			}
		}
	}
}

// Find actors in the beam
function GetTouchingActors()
{
	local Vector targetPos, A, B, Q;
	local Actor currTarget;

	mBeamedActors.Length=0;
	foreach CollidingActors(class'Actor', currTarget, beamHeight, Location + (vect(0, 0, -1) * beamHeight))
	{
	    if(ShouldIgnoreActor(currTarget))
		{
			//WorldInfo.Game.Broadcast(self, "Ignored Extra Target :" $ currTarget);
			continue;
		}

		targetPos = currTarget.Location;
		if(GGPawn(currTarget) != none)
		{
			targetPos = GGPawn(currTarget).Mesh.GetPosition();
		}
		A = Location;
		B = A + (vect(0, 0, -2) * beamHeight);
		Q = A + Normal( B - A ) * ((( B - A ) dot ( targetPos - A )) / VSize( A - B ));
		if(VSize( targetPos - Q ) < beamRadius)
		{
			//WorldInfo.Game.Broadcast(self, "actorFound=" $ currTarget);
			mBeamedActors.AddItem(currTarget);
		}
	}
}

function bool ShouldIgnoreActor(Actor act)
{
	if(bDriving)
	{
		return act == self
			|| act == none
			|| (GGPawn(act) == none && GGKActor(act) == none && GGSVehicle(act) == none);
	}
	else
	{
		return act != UFOOwner;
	}
}

function AddItemToHold(Actor act)
{
	if(GGPawn(act) != none && PlayerController(GGPawn(act).Controller) != none)
	{
		TryToDrive(GGPawn(act));
	}
	else if( GGInventoryActorInterface( act ) != none )
	{
		mHold.AddToInventory( act );
		shouldPopulate=true;
	}
}

simulated event RigidBodyCollision( PrimitiveComponent hitComponent, PrimitiveComponent otherComponent, const out CollisionImpactData rigidCollisionData, int contactIndex )
{
	super.RigidBodyCollision( hitComponent, otherComponent, rigidCollisionData, contactIndex );

	if( otherComponent == none || otherComponent.Owner == none )
	{
		return;
	}
	//WorldInfo.Game.Broadcast(self, "RigidBodyCollision=" $ otherComponent.Owner);
	Collided( otherComponent.Owner, otherComponent, , rigidCollisionData.TotalNormalForceVector, false );
}

/**
 * Call when a collision occurs. All logic in one place!
 */
function Collided( Actor other, optional PrimitiveComponent otherComp, optional vector hitLocation, optional vector hitNormal, optional bool shouldAddMomentum )
{
	super.Collided(other, otherComp, hitLocation, hitNormal, shouldAddMomentum);

	if(mBeamedActors.Find(other) != INDEX_NONE)
	{
		AddItemToHold(other);
	}
}

/*********************************************************************************************
 SCORE ACTOR INTERFACE
*********************************************************************************************/

/**
 * Human readable name of this actor.
 */
function string GetActorName()
{
	return mScoreActorName;
}

/**
 * How much score this actor gives.
 */
function int GetScore()
{
	return mScore;
}

/*********************************************************************************************
 END SCORE ACTOR INTERFACE
*********************************************************************************************/

/**
 * Only care for collisions at a certain interval.
 */
function bool IsPreviousCollisionTooRecent()
{
	local float timeSinceLastCollision;

	timeSinceLastCollision = WorldInfo.TimeSeconds - mLastCollisionData.CollisionTimestamp;

	return timeSinceLastCollision < mMinTimeBetweenCollisions;
}

function bool ShouldCollide( Actor other )
{
	local GGGoat goatDriver, goatPassenger;
	local int i;

	goatDriver = GGGoat( Driver );

	if( other == Driver || IsPreviousCollisionTooRecent() || ( goatDriver != none && goatDriver.mGrabbedItem == other ) )
	{
		return false;
	}

	for( i = 0; i < mPassengerSeats.Length; i++)
	{
		goatPassenger = GGGoat( mPassengerSeats[ i ].PassengerPawn );

		if( goatPassenger != none && goatDriver.mGrabbedItem == other )
		{
			// We do not want to collide with stuff carried by driver or passengers.
			return false;
		}
	}

	return true;
}

/*********************************************************************************************
 GRABBABLE ACTOR INTERFACE
*********************************************************************************************/

function bool CanBeGrabbed( Actor grabbedByActor, optional name boneName = '' )
{
	return false;
}

function OnGrabbed( Actor grabbedByActor );
function OnDropped( Actor droppedByActor );

function name GetBoneName( vector grabLocation )
{
	return '';
}

function PrimitiveComponent GetGrabbableComponent()
{
	return CollisionComponent;
}

function GGPhysicalMaterialProperty GetPhysProp()
{
	return none;
}

/*********************************************************************************************
 END GRABBABLE ACTOR INTERFACE
*********************************************************************************************/

/**
 * Set the tire sound based on how the bike is being ridden.
 */
function SetTireSound()
{
	if( bDriving && isMoving)
	{
		// Moving
		SetActiveTireSound( 0 );
	}
	else if( bDriving )
	{
		// Static
		SetActiveTireSound( 1 );
	}
	else
	{
		// Without driver
		SetActiveTireSound( 1 );
	}

	if(!mTireAudioComp.IsPlaying())
	{
		mTireAudioComp.Play();
	}
}

function Crash( Actor other, vector hitNormal );//Nope

function bool ShouldCrashKickOutDriver( vector hitVelocity, vector otherHitVelocity )
{
	return false;
}

function ToggleInventory(Controller cntr)
{
	local GGPlayerInputGame localInput;

	localInput = GGPlayerInputGame( PlayerController( cntr ).PlayerInput );
	mHold.ToggleOpen();
	shouldPopulate=true;

	localInput.Outer.mInventoryOpen = !localInput.Outer.mInventoryOpen;
	localInput.GoToState( localInput.Outer.mInventoryOpen ? 'InventoryOpen' : '' );
}

function OnInventoryItemClicked( GGUIScrollingList Sender, GFxObject ItemRenderer, int Index, int ControllerIdx, int ButtonIdx, bool IsKeyboard )
{
	if( mHUD.mInventoryOpen )
	{
		RemoveFromInventory( Index );
	}
}

function RemoveFromInventory( int index )
{
	mHold.RemoveFromInventory( index );
	shouldPopulate=true;
}

function PopulateInventory()
{
	local int i;
	local GFxObject tempObject, dataProviderArray, dataProviderObject;
	local array<ASValue> args;

	shouldPopulate=false;
	dataProviderArray = mHUD.CreateArray();

	for( i = 0; i < mHold.mInventorySlots.Length; ++i )
	{
		//WorldInfo.Game.Broadcast(self, "inventoryItem=" $ mHold.mInventorySlots[ i ].mName);
		tempObject = mHUD.CreateObject( "Object" );

		tempObject.SetString( "label", mHold.mInventorySlots[ i ].mName );

		dataProviderArray.SetElementObject( i, tempObject );
	}

	dataProviderObject = mHUD.mRootMC.CreateDataProviderFromArray( dataProviderArray );

	mHUD.mInventory.SetObject( "dataProvider", dataProviderObject );

   	args.Length = 0;
	mHUD.mInventory.Invoke( "validateNow", args );
	mHUD.mInventory.Invoke( "invalidateData", args );
}

function AddEasterEgg(optional int eeID)
{
	local Actor easterEggAct;
	local GGNpc easterEggNpc;
	local GGKactor easterEggKact;

	if(eeID == 0)
	{
		eeID=Rand(10)+1;
	}
	switch(eeID)
	{
		case 1:
			easterEggNpc=Spawn(class'UFONpcSheep', self,,,,, true);
			break;
		case 2:
			easterEggNpc=Spawn(class'GGNpcGoat', self,,,,, true);
			easterEggNpc.mesh.SetMaterial(0, goatMaterials[Rand(goatMaterials.Length)]);
			break;
		case 3:
			easterEggNpc=Spawn(class'GGNpc', self,,,,, true);
			easterEggNpc.mesh.SetSkeletalMesh( SkeletalMesh'Human_Characters.mesh.Alien_01' );
			easterEggNpc.mesh.SetMaterial( 0, MaterialInstanceConstant'Human_Characters.Materials.Alien_Bob_INST' );
			alienHead.SetLightEnvironment( easterEggNpc.mesh.LightEnvironment );
			easterEggNpc.mesh.AttachComponentToSocket( alienHead, 'AlienSocket' );
			break;
		case 4:
			easterEggNpc=Spawn(class'UFONpcWhale', self,,,,, true);
			break;
		case 5:
			easterEggNpc=Spawn(class'UFONpcTRex', self,,,,, true);
			break;
		case 6:
			easterEggNpc=Spawn(class'UFONpcCow', self,,,,, true);
			break;
		case 7:
			easterEggNpc=Spawn(class'GGNpc', self,,,,, true);
			easterEggNpc.mesh.SetSkeletalMesh( SkeletalMesh'Explorer.mesh.Explorer' );
			easterEggNpc.SetReactionSounds();
			break;
		case 8:
			easterEggKact=Spawn(class'UFOAsteroid', self,,,,, true);
			break;
		case 9:
			easterEggKact=Spawn(class'GGKActorSpawnable', self,,,,, true);
			easterEggKact.StaticMeshComponent.SetStaticMesh( StaticMesh'Beacon.mesh.Beacon' );
			break;
		case 10:
			easterEggNpc=Spawn(class'GGNpc', self,,,,, true);
			SetRandomMesh(easterEggNpc);
			easterEggNpc.SetReactionSounds();
			break;
	}
	if(easterEggKact != none)
	{
		easterEggKact.StaticMeshComponent.WakeRigidBody();
		easterEggAct=easterEggKact;
	}
	if(easterEggNpc != none)
	{
		easterEggNpc.SetRagdoll(true);
		easterEggAct=easterEggNpc;
	}
	//WorldInfo.Game.Broadcast(self, "easterEggAct=" $ easterEggAct);
	AddItemToHold(easterEggAct);
}

function SetRandomMesh(GGNpc npc)
{
	local GGNPc npcItr;
	local array< GGNpc > someNPCs;

	foreach WorldInfo.AllPawns( class'GGNpc', npcItr )
	{
		if( npcItr.mesh.SkeletalMesh != none
		 && npcItr.mesh.PhysicsAsset != none
	 	 && npcItr.mesh.Materials.Length > 0
		 && npcItr.mesh.Materials[ 0 ] != none  )
		{
			someNPCs.AddItem( npcItr );
		}
	}

	npcItr = someNPCs[ Rand( someNPCs.Length ) ];
	npc.SetMesh( npcItr.mesh.SkeletalMesh, npcItr.mesh.PhysicsAsset, npcItr.mesh.Materials[ 0 ] );
	npc.mesh.SetAnimTreeTemplate(npcItr.mesh.AnimTreeTemplate);
	npc.mesh.AnimSets[0]=npcItr.mesh.AnimSets[0];
}

/**
 * Called when a pawn is possessed by a controller.
 */
function NotifyOnPossess( Controller C, Pawn P )
{
	local int i;

	if(P == self)
	{
		ModifyCameraZoom(PlayerController(C));
	}
	for( i = 0; i < mPassengerSeats.Length; i++ )
	{
		if( mPassengerSeats[ i ].VehiclePassengerSeat == P )
		{
			ModifyCameraZoom(PlayerController(C), false, true);
		}
	}
}

/**
 * Called when a pawn is unpossessed by a controller.
 */
function NotifyOnUnpossess( Controller C, Pawn P )
{
	local int i;

	if(P == self)
	{
		ModifyCameraZoom( PlayerController(C), true);
	}
	for( i = 0; i < mPassengerSeats.Length; i++ )
	{
		if( mPassengerSeats[ i ].VehiclePassengerSeat == P )
		{
			ModifyCameraZoom(PlayerController(C), true, true);
		}
	}
}

DefaultProperties
{
	// --- UFOVehicle
	mVehicleCheckRadius=1000.f

	mMinTimeBetweenCollisions=1.0f

	mScoreActorName="U.F.O."
	mScore=4200

	mJumpForceSize=100000000.0f

	spinRate=-25400.f
	initRotation=(Pitch=0, Yaw=0, Roll=16384)

	mOpenCloseAnimTime=1.2f
	attractionForce=500.f
	beamHeight=5000.f
	beamRadius=400.f

	keypressedcount=0

	holdRange=400.f

	// --- GGSVehicle
	mGentlePushForceSize=3700.0f

	mNumberOfSeats=3

	mDriverSocketName=""

	mCameraLookAtOffset=(X=0.0f,Y=0.0f,Z=0.0f)
	CamDist=3000.f

	// --- Actor
	bNoEncroachCheck=true
	mBlockCamera=false

	// --- Pawn
	ViewPitchMin=-16000
	ViewPitchMax=16000

	GroundSpeed=4200
	AirSpeed=4200

	// --- SVehicle
	// The speed of the vehicle is controlled by MaxSpeed, GroundSpeed, AirSpeed and TorqueVSpeedCurve
	MaxSpeed=4200					// Absolute max physics speed
	MaxAngularVelocity=110000.0f	// Absolute max physics angular velocity (Unreal angular units)

	COMOffset=(x=0.0f,y=0.0f,z=0.0f)

	bDriverIsVisible=false

	Begin Object Name=CollisionCylinder
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		BlockRigidBody=false
		CollideActors=false
	End Object

	CollisionSound=SoundCue'Goat_Sounds_Impact.Cue.Impact_Car_Cue'

	Begin Object class=AnimNodeSequence Name=MyMeshSequence
    End Object

	Begin Object name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'UFO.Mesh.UFO_Skele_01'
		PhysicsAsset=PhysicsAsset'UFO.mesh.UFO_Skele_01_Physics'//This have a crappy collision box
		Animations=MyMeshSequence
		AnimSets(0)=AnimSet'UFO.Anim.UFO_Anim_01'
		bHasPhysicsAssetInstance=true
		RBChannel=RBCC_Vehicle
		RBCollideWithChannels=(Untitled2=false,Untitled3=true,Vehicle=true)
		bNotifyRigidBodyCollision=true
		ScriptRigidBodyCollisionThreshold=1
		Rotation=(Pitch=-16384,Yaw=0,Roll=0)
	End Object

	Begin Object Class=UDKVehicleSimCar Name=SimulationObject
		bClampedFrictionModel=true
		TorqueVSpeedCurve=(Points=((InVal=-600.0,OutVal=0.0),(InVal=-300.0,OutVal=130.0),(InVal=0.0,OutVal=210.0),(InVal=900.0,OutVal=130.0),(InVal=1450.0,OutVal=10.0),(InVal=1850.0,OutVal=0.0)))
		MaxSteerAngleCurve=(Points=((InVal=0,OutVal=35),(InVal=500.0,OutVal=18.0),(InVal=700.0,OutVal=14.0),(InVal=900.0,OutVal=9.0),(InVal=970.0,OutVal=7.0),(InVal=1500.0,OutVal=3.0)))
		SteerSpeed=85
		NumWheelsForFullSteering=2
		MaxBrakeTorque=200.0f
		EngineBrakeFactor=0.08f
	End Object
	SimObj=SimulationObject
	Components.Add(SimulationObject)

	Begin Object class=StaticMeshComponent Name=StaticMeshComp1
		StaticMesh=StaticMesh'Human_Characters.Textures.Alien_Head'
	End Object
	alienHead=StaticMeshComp1

	// Vehicle
	ExitPositions(0)=(X=0.0f,Y=0.0f,Z=-300.0f)
	ExitPositions(1)=(X=0.0f,Y=700.0f,Z=300.0f)
	ExitPositions(2)=(X=0.0f,Y=-700.0f,Z=300.0f)
	ExitPositions(3)=(X=700.0f,Y=0.0f,Z=300.0f)
	ExitPositions(4)=(X=-700.0f,Y=0.0f,Z=300.0f)

	goatMaterials(0)=Material'goat.Materials.Goat_Mat_01'
	goatMaterials(1)=Material'goat.Materials.Goat_Mat_04'
	goatMaterials(2)=Material'goat.Materials.Goat_Mat_05'
	goatMaterials(3)=Material'goat.Materials.Goat_Mat_07'

	mBeamEndSoundCue=SoundCue'Heist_Audio.Cue.SFX_SpaceShip_Beam_End_Mono_Cue'
	mBeamStartSoundCue=SoundCue'Heist_Audio.Cue.SFX_SpaceShip_Beam_Up_Mono_Cue'

	mSaucerBeepSoundCue=SoundCue'Heist_Audio.Cue.SFX_SpaceShip_Beep_Mono_Cue'
	mSuacerLoopSoundCue=SoundCue'Heist_Audio.Cue.SFX_SpaceShip_Loop_Mono_Cue'
}
