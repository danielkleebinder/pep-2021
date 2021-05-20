------------------------------------------------------------------------------
--                                                                          --
--                     Parallel and Real-Time Computing                     --
--                                                                          --
--                            E X E R C I S E  3                            --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                             Daniel Kleebinder                            --
--                                                                          --
-- This railway simulation tries to simulate all possible scenarios for a   --
-- given railway system. It uses tasks and protected objects to simulate th --
-- e traffic on those tracks. Some of these scenarios will inevitably lead  --
-- to deadlocks which are also handled by this application. The railway sys --
-- tem looks like the following:                                            --
--                                                                          --
--                    __1_____                 _____5__                     --
--                            \               /                             --
--                    __2______\______3______/______4__                     --
--                                                                          --
-- Three distinct trains try to drive throught this system without blocking --
-- each other.                                                              --
--                                                                          --
------------------------------------------------------------------------------


with Ada.Text_IO, Ada.Calendar,
     Railway.Simulation,
     Railway.Trains,
     Railway.Tracks;

use Ada.Text_IO, Ada.Calendar,
    Railway.Simulation,
    Railway.Trains,
    Railway.Tracks;


procedure Main is

   -- I just wanted some metrics for later on
   Program_Start_Time : Time := Clock;
   Total_Count    : Natural := 0;
   Success_Count  : Natural := 0;
   Deadlock_Count : Natural := 0;


   -- Prints the simulation results in a humanly readable fashion.
   procedure Print_Simulation_Result(L1_Schedule : Train_Schedule_Ptr;
                                     L2_Schedule : Train_Schedule_Ptr;
                                     L3_Schedule : Train_Schedule_Ptr;
                                     Success : Boolean) is
      L1 : Train_Schedule := L1_Schedule.all;
      L2 : Train_Schedule := L2_Schedule.all;
      L3 : Train_Schedule := L3_Schedule.all;
   begin
      Put_Line("  L1 goes from" & Track_System_Index'Image(L1.Route(1)) & " to" & Track_System_Index'Image(L1.Route(3)) & " with departure time" & Duration'Image(L1.Departure));
      Put_Line("  L2 goes from" & Track_System_Index'Image(L2.Route(1)) & " to" & Track_System_Index'Image(L2.Route(3)) & " with departure time" & Duration'Image(L2.Departure));
      Put_Line("  L3 goes from" & Track_System_Index'Image(L3.Route(1)) & " to" & Track_System_Index'Image(L3.Route(3)) & " with departure time" & Duration'Image(L3.Departure));
      Put_Line("    -> " & (if Success then "Successful Simulation" else "Deadlock"));
      Put_Line("");
   end Print_Simulation_Result;


   -- Runs a single scenario using the Railway package. Also keeps track of successful and
   -- non-successful simulations and prints it.
   procedure Run_Scenario(L1_Time : Duration; L1_Departure : Track_System_Index; L1_Destination : Track_System_Index;
                          L2_Time : Duration; L2_Departure : Track_System_Index; L2_Destination : Track_System_Index;
                          L3_Time : Duration; L3_Departure : Track_System_Index; L3_Destination : Track_System_Index) is
      Success : Boolean := False;
      Train_L1_Schedule : Train_Schedule_Ptr := new Train_Schedule'(L1_Time, (L1_Departure, 3, L1_Destination));
      Train_L2_Schedule : Train_Schedule_Ptr := new Train_Schedule'(L2_Time, (L2_Departure, 3, L2_Destination));
      Train_L3_Schedule : Train_Schedule_Ptr := new Train_Schedule'(L3_Time, (L3_Departure, 3, L3_Destination));
   begin
      Success := Simulate(Train_L1_Schedule,
                          Train_L2_Schedule,
                          Train_L3_Schedule);

      Total_Count := Total_Count + 1;
      Print_Simulation_Result(Train_L1_Schedule,
                              Train_L2_Schedule,
                              Train_L3_Schedule,
                              Success);

      if Success then
         Success_Count := Success_Count + 1;
      else
         Deadlock_Count := Deadlock_Count + 1;
      end if;

   end Run_Scenario;

   -- Some auxiliary variables to compute the correct destination track for each train
   Dest1, Dest2, Dest3 : Track_System_Index;

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
   Put_Line("Please lean back a little, this simulation takes around 2 minutes :-)");
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

               -- Go through all the possible destination tracks.
               for D1 in 1..2 loop
                  for D2 in 1..2 loop
                     for D3 in 1..2 loop

                        -- I have to make sure that trains always drive from one side to the other
                        Dest1 := Track_System_Index(if L1 < 3 then 3 + D1 else D1);
                        Dest2 := Track_System_Index(if L2 < 3 then 3 + D2 else D2);
                        Dest3 := Track_System_Index(if L3 < 3 then 3 + D3 else D3);

                        if
                          -- Just used to allow future developer of the application to test certain conditions
                          -- in this if-statement.
                          True

                          -- It makes no sense that two trains drive to the same destination, they will
                          -- create a deadlock anyways. So I allow myself to skip this simulation in this
                          -- place. You can enable it if you want to. The simulation time will double.
                          and Dest1 /= Dest2 and Dest2 /= Dest3 and Dest3 /= Dest1

                          -- Also if two trains try to swap their location it will lead to a deadlock. This
                          -- is due to the fact, that trains cannot drive to a track where they temporarily
                          -- stay until the swap was done. You can enable these scenarios if you want. The
                          -- simulation time will again double.
                          and (not (L1 = Dest2 and L2 = Dest1))
                          and (not (L1 = Dest3 and L3 = Dest1))
                          and (not (L2 = Dest3 and L3 = Dest2))
                        then

                           -- I directly unrolled this 3-dimensional for loop to just the 6 distinct
                           -- departure time calls. This makes the program code less complex and a
                           -- tiny bit more performant.
                           Run_Scenario(0.02, L1, Dest1, 0.04, L2, Dest2, 0.06, L3, Dest3);
                           Run_Scenario(0.02, L1, Dest1, 0.06, L2, Dest2, 0.04, L3, Dest3);
                           Run_Scenario(0.04, L1, Dest1, 0.02, L2, Dest2, 0.06, L3, Dest3);
                           Run_Scenario(0.04, L1, Dest1, 0.06, L2, Dest2, 0.02, L3, Dest3);
                           Run_Scenario(0.06, L1, Dest1, 0.02, L2, Dest2, 0.04, L3, Dest3);
                           Run_Scenario(0.06, L1, Dest1, 0.04, L2, Dest2, 0.02, L3, Dest3);
                        end if;
                     end loop;
                  end loop;
               end loop;


            end if;

         end loop;
      end loop;
   end loop;


   -- Done, print some metrics and say bye to our user
   Put_Line("");
   Put_Line("Ran" & Natural'Image(Total_Count) & " distinct scenarios with");
   Put_Line("  -" & Natural'Image(Success_Count) & " successful simulations and");
   Put_Line("  -" & Natural'Image(Deadlock_Count) & " deadlocks");
   Put_Line("Program runtime was" & Duration'Image(Clock - Program_Start_Time) & " seconds");
   Put_Line("Thank you for using this railway simulator <3");
   Put_Line("");

end Main;

