//flags for outfits that have mutant variants: Most of these require additional sprites to work.
#define STYLE_DIGITIGRADE		(1<<0) //jumpsuits, suits and shoes
#define STYLE_MUZZLE			(1<<1) //hats or masks
#define STYLE_TAUR_SNAKE		(1<<2) //taur-friendly suits
#define STYLE_TAUR_PAW			(1<<3)
#define STYLE_TAUR_HOOF			(1<<4)
#define STYLE_TAUR_ALL		(STYLE_TAUR_SNAKE|STYLE_TAUR_PAW|STYLE_TAUR_HOOF)
#define STYLE_VOX			(1<<5) //For glasses, masks and head pieces for the Vox race

//Flags for bodytypes for species and clothing. If a clothing doesnt have a flag for a species, they cant wear the clothing
#define BODYTYPE_HUMANOID		(1<<0)
#define BODYTYPE_VOX			(1<<1)
#define BODYTYPE_TESHARI		(1<<2)
#define ALL_BODYTYPES		(BODYTYPE_HUMANOID|BODYTYPE_VOX|BODYTYPE_TESHARI)
//Bodytypes *mostly* resembling a humanoid, this is set on things by default
#define GENERIC_BODYTYPES		(BODYTYPE_HUMANOID|BODYTYPE_VOX)
