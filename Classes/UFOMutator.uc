class UFOMutator extends GGMutator;

struct GoatUFO
{
	var GGGoat mGoat;
	var UFOVehicle mUFO;
};
var array<GoatUFO> mGoatUFOs;


/**
 * See super.
 */
function ModifyPlayer(Pawn Other)
{
	local GGGoat goat;

	goat = GGGoat( other );
	if( goat != none )
	{
		if( IsValidForPlayer( goat ) )
		{
			AddGoatUFO(goat);
		}
	}

	super.ModifyPlayer( other );
}

function AddGoatUFO(GGGoat goat)
{
	local GoatUFO newGoatUFO;

	if(mGoatUFOs.Find('mGoat', goat) == INDEX_NONE)
	{
		newGoatUFO.mGoat=goat;
		mGoatUFOs.AddItem(newGoatUFO);
	}
}

simulated event Tick( float deltaTime )
{
	local int i;

	super.Tick( deltaTime );

	for(i=0 ; i<mGoatUFOs.Length ; i++)
	{
		if(mGoatUFOs[i].mGoat == none || mGoatUFOs[i].mGoat.bPendingDelete)
			continue;

		if(mGoatUFOs[i].mUFO == none || mGoatUFOs[i].mUFO.bPendingDelete)
		{
			mGoatUFOs[i].mUFO=Spawn(class'UFOVehicle', mGoatUFOs[i].mGoat,, mGoatUFOs[i].mGoat.Location + (vect(0, 0, 1) * (3000 + (mGoatUFOs[i].mGoat.mCachedSlotNr * 1000))));
		}

		mGoatUFOs[i].mUFO.currentBaseY=PlayerController( mGoatUFOs[i].mUFO.Controller ).PlayerInput.aBaseY;
		mGoatUFOs[i].mUFO.currentStrafe=PlayerController( mGoatUFOs[i].mUFO.Controller ).PlayerInput.aStrafe;
	}
}

/**
 * Called when a pawn is possessed by a controller.
 */
function NotifyOnPossess( Controller C, Pawn P )
{
	local int i;

	super.NotifyOnPossess(C, P);

	for(i=0 ; i<mGoatUFOs.Length ; i++)
	{
		mGoatUFOs[i].mUFO.NotifyOnPossess(C, P);
	}
}

/**
 * Called when a pawn is unpossessed by a controller.
 */
function NotifyOnUnpossess( Controller C, Pawn P )
{
	local int i;

	super.NotifyOnUnpossess(C, P);

	for(i=0 ; i<mGoatUFOs.Length ; i++)
	{
		mGoatUFOs[i].mUFO.NotifyOnUnpossess(C, P);
	}
}

DefaultProperties
{

}