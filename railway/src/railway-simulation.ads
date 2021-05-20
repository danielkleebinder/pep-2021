------------------------------------------------------------------------------
--                                                                          --
--                     Parallel and Real-Time Computing                     --
--                                                                          --
--                   R A I L W A Y  .  S I M U L A T I O N                  --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                             Daniel Kleebinder                            --
--                                                                          --
-- A helper package used to better separate the scenario specific concerns  --
-- from the general railway concerns.                                       --
--                                                                          --
------------------------------------------------------------------------------

with Railway.Trains;
use Railway.Trains;

package Railway.Simulation is


   -- Simulates a single scenario using the given schedules for the three lines. This
   -- function will return true if the simulation was successful and false if some
   -- certain constellation duration the simulation lead to a deadlock.
   function Simulate(L1_Schedule : Train_Schedule_Ptr;
                     L2_Schedule : Train_Schedule_Ptr;
                     L3_Schedule : Train_Schedule_Ptr) return Boolean;
   

end Railway.Simulation;
