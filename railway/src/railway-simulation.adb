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
         -- 0.1 seconds should be enough to allow all trains to arrive at their
         -- destination track. If not, we abort because we ran into a deadlock.
         delay 0.1;
         abort Train_L1;
         abort Train_L2;
         abort Train_L3;
         return False;
      then abort
         -- Hopefully all trains arrive in time ;-)
         Train_L1.Arrived;
         Train_L2.Arrived;
         Train_L3.Arrived;
      end select;
      return True;
   end Simulate;

   
end Railway.Simulation;
