with Railway.Trains, Railway.Tracks;
use Railway.Trains, Railway.Tracks;


package body Railway.Simulation is


   function Simulate(L1_Schedule : Train_Schedule_Ptr;
                     L2_Schedule : Train_Schedule_Ptr;
                     L3_Schedule : Train_Schedule_Ptr) return Boolean is
      Tracks   : Track_System_Ptr := new Track_System;
      Train_L1 : Train (Tracks, L1_Schedule);
      Train_L2 : Train (Tracks, L2_Schedule);
      Train_L3 : Train (Tracks, L3_Schedule);
   begin
      select
         delay 0.1;
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

   
end Railway.Simulation;
