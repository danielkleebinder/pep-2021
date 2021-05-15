with Railway.Tracks;
use Railway.Tracks;

package body Railway.Trains is

   
   task body Train is
   begin
      loop
         select
            accept Drive (Departure : Natural;
                          Destination: Natural;
                          Tracks : Tracks_Array) do
               
               -- Tracks(3).Enter;
               delay 1.0;
               -- Tracks(Departure).Leave;
               delay 1.0;
               -- Tracks(Destination).Enter;
               delay 1.0;
               -- Tracks(3).Leave;
               delay 1.0;
            end Drive;
            
            accept Arrived;
         end select;
      end loop;
   end Train;
   

end Railway.Trains;
