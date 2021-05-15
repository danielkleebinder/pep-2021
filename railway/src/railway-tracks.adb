package body Railway.Tracks is

   
   protected body Track_Section is
      procedure Enter is begin Occupied := True; end Enter;
      procedure Leave is begin Occupied := False; end Leave;
      function Is_Occupied return Boolean is begin return Occupied; end Is_Occupied;
   end Track_Section;
   

end Railway.Tracks;
