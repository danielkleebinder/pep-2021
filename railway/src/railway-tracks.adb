package body Railway.Tracks is

   
   protected body Track_Section is
      procedure Occupy is begin Occupied := True; end Occupy;
      procedure Release is begin Occupied := False; end Release;
      function Is_Occupied return Boolean is begin return Occupied; end Is_Occupied;
   end Track_Section;
   

end Railway.Tracks;
