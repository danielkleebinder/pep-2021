------------------------------------------------------------------------------
--                                                                          --
--                     Parallel and Real-Time Computing                     --
--                                                                          --
--                       R A I L W A Y  .  T R A C K S                      --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                             Daniel Kleebinder                            --
--                                                                          --
-- This package provides the tracks of the railway system. The tracks are   --
-- implemented as protected objects since only one train can occupy a certa --
-- in track section at a time.                                              --
--                                                                          --
-- Use this package to model your tracks and your train simulation.         --
--                                                                          --
------------------------------------------------------------------------------

package Railway.Tracks is
   
   
   -- Every track section of the railway system is a protected object which trains
   -- can occupy and release at any time. Be careful: Entering and leaving a track
   -- section might lead to deadlocks since track can only be entered if they are
   -- free at the time.
   protected type Track_Section is
      entry Enter;
      procedure Leave;
      function Is_Occupied return Boolean;
   private
      Occupied : Boolean := False;
   end Track_Section;
   
   
   -- The track system is used to model a bunch of tracks that are connected
   -- with each other in some sense. How those connections look like is left to
   -- the user of this package.
   type Track_System_Index is range 1..5;
   type Track_System is array (Track_System_Index) of Track_Section;
   type Track_System_Ptr is access Track_System;
   
   
   -- Track routes are used to model path through a track system.
   type Track_Route_Index is range 1..3;
   type Track_Route is array (Track_Route_Index) of Track_System_Index;

   
end Railway.Tracks;
