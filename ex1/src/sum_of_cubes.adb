package body Sum_Of_Cubes is


   protected body Compute_Master is
      procedure Set_Result(Result : Ptr_Sum_Of_Cubes_Record) is begin
         -- I am only interested in the first result found
         if Ptr_Result = null then Ptr_Result := Result; end if;
      end Set_Result;
      procedure Reset is begin Ptr_Result := null; Ptr_Index := new Index_Record'(I => 0); end Reset;
      function Next_Index return Long_Long_Integer is begin Ptr_Index.I := Ptr_Index.I + 1; return Ptr_Index.I - 1; end Next_Index;
      function Has_Result return Boolean is begin return Ptr_Result /= null; end Has_Result;
      function Get_Result return Sum_Of_Cubes_Record is begin return Ptr_Result.all; end Get_Result;
   end Compute_Master;
   
   
   task body Compute_Task is
      Step_Size : constant Long_Long_Integer := 50;
      Aq, Bq, Cq : Long_Long_Integer := 0;
      From, To : Long_Long_Integer;
      LLN : Long_Long_Integer := Long_Long_Integer(N);
   begin
      Task_Loop:
      loop
         From := Compute_Master.Next_Index * Step_Size + 1;
         To := From + Step_Size;

         --
         -- Generates 3-tuples from "From" to "To"
         --
         -- Example:
         --   From := 1, To := 3
         --   [ (1,1,1), (1,1,2), (1,1,3),
         --     (1,2,1), (1,2,2), (1,2,3),
         --     (1,3,1), (1,3,2), (1,3,3), ...]
         --
         -- Those tuples are then used to check all possible A³, B³ and C³ combinations
         --
         for A in From..To loop
            Aq := A**3;

            for B in 1..To loop
               Bq := B**3;

               -- Asking too often if the compute master has a result, will lead to INSANE performance issues the
               -- more tasks we use for our computation. Moving this to the inner-most loop will result in a
               -- #ofTasks^3 performance decrease.
               --
               -- Emperical observations have shown, that moving this exit condition out of the inner-most loop
               -- improves the performance from ~10 seconds (K=3, R=29) to ~0.35 seconds (K=3, R=29).
               exit Task_Loop when Compute_Master.Has_Result;
               
               -- I added this delay as a dispatching point. Typically the tasks are aborted really quick on timeout,
               -- however, certain operating system might have trouble scheduling the abort correctly. Since the Ada
               -- specification promises, that an abort statement IS GOING TO BE EXECUTED at latest when entering a
               -- new dispatching point, this should do the trick to make this program the best it can be on every OS.
               delay 0.0;

               
               for C in 1..To loop
                  Cq := C**3;

                  -- Test for all combinations if any fits the sum of cubes.
                  -- The compute master will assure, that only the first value will be used and cannot be overwritten.
                  if Aq + Bq + Cq = LLN then Compute_Master.Set_Result(new Sum_Of_Cubes_Record'(A, B, C)); exit Task_Loop;
                  elsif Aq + Bq - Cq = LLN then Compute_Master.Set_Result(new Sum_Of_Cubes_Record'(A, B, -C)); exit Task_Loop;
                  elsif Aq - Bq - Cq = LLN then Compute_Master.Set_Result(new Sum_Of_Cubes_Record'(A, -B, -C)); exit Task_Loop;
                  elsif Aq - Bq + Cq = LLN then Compute_Master.Set_Result(new Sum_Of_Cubes_Record'(A, -B, C)); exit Task_Loop;
                  end if;

               end loop;
            end loop;
         end loop;
      end loop Task_Loop;

      accept Wait_For_Termination;
   end Compute_Task;
   

   function Compute_Sum_Of_Cubes(N : Positive; Num_Of_Tasks : Positive; Timeout : Duration := 0.0) return Sum_Of_Cubes_Record is
      Result : Sum_Of_Cubes_Record;
      procedure Multi_Task_Compute is
         Compute_Task_Array : array (0..Num_Of_Tasks) of Compute_Task(N);
      begin
         if Timeout > 0.0 then
            select

               -- Delay T seconds if T is greater than 0. If this delay cannot be fulfilled
               -- abort all the tasks.
               delay Timeout;

               -- My implementation works a little bit different. Every time the compute sum
               -- of cubes function is invoked, N new tasks are created. Therefore I have to
               -- abort all of them here, otherwise the Multi_Task_Compute function would
               -- never terminate.
               for J in Compute_Task_Array'Range loop abort Compute_Task_Array(J); end loop;
            then abort

               -- Wait for the termination of all the tasks. If this does not happen within
               -- T seconds, then abort.
               for J in Compute_Task_Array'Range loop Compute_Task_Array(J).Wait_For_Termination; end loop;
            end select;
         else
            for J in Compute_Task_Array'Range loop Compute_Task_Array(J).Wait_For_Termination; end loop;
         end if;
      end Multi_Task_Compute;
   begin
      Multi_Task_Compute;
      if Compute_Master.Has_Result then
         Result := Compute_Master.Get_Result;
      end if;
      Compute_Master.Reset;
      return Result;
   end Compute_Sum_Of_Cubes;
   

end Sum_Of_Cubes;
