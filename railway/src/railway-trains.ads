------------------------------------------------------------------------------
--                                                                          --
--                     Parallel and Real-Time Computing                     --
--                                                                          --
--                       R A I L W A Y  .  T R A I N S                      --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                             Daniel Kleebinder                            --
--                                                                          --
-- This package provides the trains of the railway system. The trains are   --
-- implemented as tasks each of which simulating some stuff trains usually  --
-- do.
--                                                                          --
------------------------------------------------------------------------------

with Railway.Tracks;
use Railway.Tracks;

package Railway.Trains is
   
   
   -- All trains run on certain schedules which include a route on which they drive and a
   -- departure time when they start from their departure track.
   type Train_Schedule is record
      Departure : Duration;
      Route     : Track_Route;
   end record;
   type Train_Schedule_Ptr is access Train_Schedule;
   
   
   -- Trains are used to drive through certain track systems using a given schedule. They
   -- will only accept the arrived entry call iff the train successfully arrived at it's
   -- destination track.
   task type Train (Tracks   : Track_System_Ptr;
                    Schedule : Train_Schedule_Ptr) is
      entry Arrived;
   end Train;


end Railway.Trains;
