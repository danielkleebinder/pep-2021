with Ada.Text_IO, Ada.Calendar, Railway.Tracks, Railway.Trains;
use Ada.Text_IO, Ada.Calendar, Railway.Tracks, Railway.Trains;


procedure Main is

   Program_Start_Time : Time := Clock;

   Simulation_Count : Natural := 0;

   Tracks : aliased Track_System;
   Trains : array (Train_Range) of Train(Tracks'Access);

   procedure Simulate(L1 : Track_Section_Range;
                      L2 : Track_Section_Range;
                      L3 : Track_Section_Range) is
   begin
      Simulation_Count := Simulation_Count + 1;

      -- Reset all track locks. We want to start with a completely new scenario.
      for I in Track_Section_Range loop
         Tracks(I).Leave;
      end loop;

      -- Occupy the track sections where the trains start from.
      Tracks(L1).Enter;
      Tracks(L2).Enter;
      Tracks(L3).Enter;

      Trains(1).Drive(Integer(L1), 5);

      Put_Line("  L1: 1 -> 4, L2: 2 -> 5, L3: 5 -> 1");
      null;
   end Simulate;


begin
   Put_Line("");
   Put_Line("    R A I L W A Y  S Y S T E M  S I M U L A T O R    ");
   Put_Line("");
   Put_Line("");
   Put_Line("Track Layout:");
   Put_Line("");
   Put_Line("          __1_____                 _____5__");
   Put_Line("                  \               /        ");
   Put_Line("          __2______\______3______/______4__");
   Put_Line("");
   Put_Line("        (using 3 trains and 5 track sections)");
   Put_Line("");
   Put_Line("");
   Put_Line("Simulations:");


   -- Start the simulation with every train on its own track. These loops will assure that
   -- every possible combination will be simulated. On 5 tracks with 3 trains that is 5^3
   -- combinations. I.e. 125.
   for L1 in Track_Section_Range loop
      for L2 in Track_Section_Range loop
         for L3 in Track_Section_Range loop

            -- Two trains cannot be on the same track at the same time and trains are not
            -- allowed to start on track 3 as well
            if L1 /= 3 and L2 /= 3 and L3 /= 3
              and L1 /= L2 and L2 /= L3 and L1 /= L3 then
               Simulate(L1, L2, L3);
            end if;

         end loop;
      end loop;
   end loop;


   Put_Line("");
   Put_Line("Ran" & Natural'Image(Simulation_Count) & " distinct scenarios");
   Put_Line("Program runtime was" & Duration'Image(Clock - Program_Start_Time) & " seconds");
   Put_Line("Thank you for using this railway simulator <3");
   Put_Line("");

end Main;
