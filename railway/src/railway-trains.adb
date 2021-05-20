with Railway.Tracks,Ada.Text_IO;
use Railway.Tracks,Ada.Text_IO;

package body Railway.Trains is
      
   task body Train is
      Departure       : Duration := Schedule.all.Departure;
      Has_Predecessor : Boolean := False;
   begin
         
      for I in Track_Route_Index loop
         Tracks.all(Schedule.all.Route(I)).Enter;
         
         if Has_Predecessor then
            -- Trains enter a new track section before leaving the previous one. So this here checks
            -- if there has been a previous track section. If so, we leave it after enterin it.
            Tracks.all(Schedule.all.Route(I - 1)).Leave;
         else
            -- All trains have a certain departure time. This is simulated by this initial delay. Trains
            -- wait on their first track for departure so to say.
            delay Departure;
         end if;
            
         Has_Predecessor := True;
      end loop;
      
      -- The train finally arrived and we did not run into some deadlock.
      accept Arrived;
         
   end Train;
   

end Railway.Trains;
