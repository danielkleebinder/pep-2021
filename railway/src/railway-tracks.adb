package body Railway.Tracks is

   
   protected body Track_Section is
      
      -- A train can only enter this train section if it is NOT occupied by any
      -- other Train at the time. Trains will wait until the section if free again.
      entry Enter
        when not Occupied is
      begin
         Occupied := True;
      end Enter;
      
      -- Trains can of course only leave a track section if it was occupied beforehand.
      entry Leave
        when Occupied is
      begin
         Occupied := False;
      end Leave;
      
      -- Returns if this track section is currently occupied or not
      function Is_Occupied return Boolean is
      begin
         return Occupied;
      end Is_Occupied;
      
   end Track_Section;
   

end Railway.Tracks;
