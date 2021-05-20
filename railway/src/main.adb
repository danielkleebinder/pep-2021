with Ada.Text_IO, Ada.Calendar, Railway.Tracks, Railway.Trains;
use Ada.Text_IO, Ada.Calendar, Railway.Tracks, Railway.Trains;


procedure Main is

   Program_Start_Time : Time := Clock;
   Simulation_Count : Natural := 0;

   function Simulate(L1_Schedule : Train_Schedule_Ptr;
                     L2_Schedule : Train_Schedule_Ptr;
                     L3_Schedule : Train_Schedule_Ptr) return Boolean is
      Tracks   : Track_System_Ptr := new Track_System;
      Train_L1 : Train (Tracks, L1_Schedule);
      Train_L2 : Train (Tracks, L2_Schedule);
      Train_L3 : Train (Tracks, L3_Schedule);
   begin
      select
         delay 1.0;
         abort Train_L1;
         abort Train_L2;
         abort Train_L3;
         return False;
      then abort
         Train_L1.Arrived;
         Train_L2.Arrived;
         Train_L3.Arrived;
      end select;
      return True;
   end Simulate;

   procedure Print_Simulation_Result(L1_Schedule : Train_Schedule_Ptr;
                                     L2_Schedule : Train_Schedule_Ptr;
                                     L3_Schedule : Train_Schedule_Ptr;
                                     Can_Be_Simulated : Boolean) is
   begin
      if Can_Be_Simulated then Put_Line("SUCCESS");
      else Put_Line("DEADLOCK"); end if;
   end Print_Simulation_Result;

   Can_Be_Simulated : Boolean := False;
   Train_L1_Schedule : Train_Schedule_Ptr := new Train_Schedule'(0.00, (1, 1, 1));
   Train_L2_Schedule : Train_Schedule_Ptr := new Train_Schedule'(0.01, (1, 1, 1));
   Train_L3_Schedule : Train_Schedule_Ptr := new Train_Schedule'(0.02, (1, 1, 1));

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
   -- every possible combination will be simulated.
   for L1 in Track_System_Index loop
      for L2 in Track_System_Index loop
         for L3 in Track_System_Index loop

            -- Two trains cannot be on the same track at the same time and trains are not
            -- allowed to start on track 3 as well
            if L1 /= 3 and L2 /= 3 and L3 /= 3
              and L1 /= L2 and L2 /= L3 and L1 /= L3 then

               Train_L1_Schedule.all.Route := (L1, 3, 1);
               Train_L2_Schedule.all.Route := (L2, 3, 2);
               Train_L3_Schedule.all.Route := (L3, 3, 4);

               Simulation_Count := Simulation_Count + 1;
               Can_Be_Simulated := Simulate(Train_L1_Schedule, Train_L2_Schedule, Train_L3_Schedule);
               Print_Simulation_Result(Train_L1_Schedule, Train_L2_Schedule, Train_L3_Schedule, Can_Be_Simulated);
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

