# How to get ACS (anatomical coordinate system) positions from Maya

## What do we need?
For every ACS parented to a bone:  
The **transformation matrix** describing the position of that ACS relative to the bone model it's parented to.

## Why do we need it?
**Short version:**  
In order to calculate things like the motion of points relative to an ACS parented to a bone, or the relative motions of two ACS (a JCS), we need to know where on the bone the ACS is placed.  

**Medium version:**  
Right now, the RBTs from XMALab constitute transformation matrices that describe the transformation, in every frame, of the bone models from CT space (an arbitrary space defined by the CT scanner) to cube space (where the bone was in vivo, relative to the calibration cube).
In order to bring the data into anatomical space, i.e. relative to an ACS placed somewhere on the bone model of interest, we need to know the position (in transformation matrix format) of that ACS relative to the bone it's parented to. 

## How? 
In practice, getting an ACS's transformation matrix is simple! Just follow these steps:

### For bone models that have already been animated

1) Open acs_template.mb in Maya. You will see the cranium and mandible have ACSs already roughly positioned at the right temporomandibular joint. Feel free to adjust their position if you'd like. Of course, for your data, you'd create and place ACSs whereever you want. 
For your data, if your bone models are already animated, you can skip steps 2-4. Since the bone models in the provided file aren't animated yet, you need to set a few keyframes with the following steps--oRel will only work if the models have keyframed positions.
    2) Select both bone models (Shift + Left click), and bring the time-slider to frame 1. 
    3) Press 'S', to set a keyframe
    4) Move the time slide to frame 2, then frame 3, setting keyframes on each. 
5) Click 'oRel' in the XROMMTools shelf, and set the Cranium bone model as the proximal element, and the Cranium ACS as the distal element. Calculate.
6) Repeat step 5 for the Mandible.
7) Export the relative positions in one CSV file per ACS. Use the exp GUI and select 'data type' as Matrix (maya format). If the bones haven't been animated and you just set keyframes at frames 1-3, set start and end frames to be 1 (we only need one frame of data, since the ACS isn't moving relative to the model). If you're working with bone models that have already been animated, set the start and end frame to be the first frame that has a keyframe (this should be the default start frame when you open the exp window).
This 'Get ACS Positions' step in the workflow needs to be repeated any time you want to use a new ACS as your proximal or distal object for any calculations--so bear that in mind and name files accordingly (read: descriptively). 

### For bone models that haven't been animated
See acs_template.mb
