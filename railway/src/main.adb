with Ada.Text_IO, Railway.Tracks, Railway.Trains;
use Ada.Text_IO, Railway.Tracks, Railway.Trains;


procedure Main is

   type Track_Section_Range is range 1..5;
   type Train_Range is range 1..3;

   -- There are 5 track sections in total...
   Track_Sections : array (Track_Section_Range) of Track_Section;

   -- ... and 3 trains driving on those tracks
   Trains : array (Train_Range) of Train;

   procedure Simulate(L1 : Track_Section_Range;
                      L2 : Track_Section_Range;
                      L3 : Track_Section_Range) is
   begin
      null;
   end Simulate;


begin
   Put_Line("Starting the Railway System Simulation");
   Put_Line("  - The following track layout is used");
   Put_Line("    ________                 ________ ");
   Put_Line("            \               /         ");
   Put_Line("    _________\_____________/_________ ");
   Put_Line("");
   Put_Line("  - With 3 trains and 5 train sections");


   -- Start the simulation with every train on its own track. These loops will assure that
   -- every possible combination will be simulated. On 5 tracks with 3 trains that is 5^3
   -- combinations. I.e. 125.
   for L1 in Track_Section_Range loop
      for L2 in Track_Section_Range loop
         for L3 in Track_Section_Range loop

            -- Two trains cannot be on the same track at the same time.
            if L1 /= L2 and L2 /= L3 and L1 /= L3 then
               Simulate(L1, L2, L3);
            end if;

         end loop;
      end loop;
   end loop;

end Main;
