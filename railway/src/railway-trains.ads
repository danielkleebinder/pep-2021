with Railway.Tracks;
use Railway.Tracks;

package Railway.Trains is
   
   
   task type Train (Tracks : access Track_System) is
      entry Drive (Departure : Natural;
                   Destination: Natural);
      entry Arrived;
   end Train;
   
   type Train_Range is range 1..3;


end Railway.Trains;
