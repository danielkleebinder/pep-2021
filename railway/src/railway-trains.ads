with Railway.Tracks;
use Railway.Tracks;

package Railway.Trains is
   
   type Tracks_Array is array (Natural range <>) of Track_Section;
   
   task type Train is
      entry Drive (Departure : Natural;
                   Destination: Natural;
                   Tracks : Tracks_Array);
      entry Arrived;
   end Train;

   
end Railway.Trains;
