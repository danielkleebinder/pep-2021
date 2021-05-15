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
   
   -- Defines additional types necessary for the simulation
   type Track_Section_Range is range 1..5;
   type Track_System is array (Track_Section_Range) of Track_Section;

   
end Railway.Tracks;
