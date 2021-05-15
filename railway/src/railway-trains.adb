with Railway.Tracks,Ada.Text_IO;
use Railway.Tracks,Ada.Text_IO;

package body Railway.Trains is

   
   task body Train is
   begin
      loop
         select
            accept Drive (Departure : Natural;
                          Destination: Natural) do
               
               -- Track := Tracks(3);
               Put_Line("Start");
               Tracks(3).Enter;
               Put_Line("Entered");
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
