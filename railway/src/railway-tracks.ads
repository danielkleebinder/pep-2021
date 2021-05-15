package Railway.Tracks is
   
   
   -- Every track section of the railway system is a protected object which trains can occupy and release
   -- at any time. Track sections also contain a pointer to the previous and the next track section.
   protected type Track_Section is
      procedure Occupy;
      procedure Release;
      function Is_Occupied return Boolean;
   private
      Occupied : Boolean := False;
   end Track_Section;

   
end Railway.Tracks;
