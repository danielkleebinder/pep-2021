with Railway.Tracks;
use Railway.Tracks;

package Railway.Trains is
   
   
   type Train_Schedule is record
      Departure : Duration;
      Route     : Track_Route;
   end record;
   
   type Train_Schedule_Ptr is access Train_Schedule;
   

   task type Train (Tracks   : Track_System_Ptr;
                    Schedule : Train_Schedule_Ptr) is
      entry Arrived;
   end Train;


end Railway.Trains;
