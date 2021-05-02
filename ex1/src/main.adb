------------------------------------------
--                                      --
--   Parallel and Real-Time Computing   --
--                                      --
--             Exercise 1               --
--                                      --
--          Daniel Kleebinder           --
--                                      --
------------------------------------------

with Ada.Text_IO, Ada.Command_Line, Ada.Calendar;
use Ada.Text_IO, Ada.Command_Line, Ada.Calendar;



procedure Main is

   Program_Start_Time : Time := Clock;

   -- REQ1: Let n >= 1 be a natural number
   R : Positive := 100;
   K : Positive := 12;
   T : Duration := 20.0;


   -- Return record for the sum of cubes containing three distinct components
   -- in their base form (A³ + B³ + C³ is the result).
   type Sum_Of_Cubes_Record is record A, B, C : Long_Long_Integer := 0; end record;
   type Ptr_Sum_Of_Cubes_Record is access Sum_Of_Cubes_Record;

   -- The index record is used to keep track of the current data index position.
   -- This value should be reset after the computation of each distinct N.
   type Index_Record is record I : Long_Long_Integer := 0; end record;
   type Ptr_Index_Record is access Index_Record;


   -- The compute master is used to accumulate results and inform the tasks
   -- that a result was already found.
   protected Compute_Master is
      procedure Set_Result(Result : Ptr_Sum_Of_Cubes_Record);
      procedure Reset;
      function Next_Index return Long_Long_Integer;
      function Has_Result return Boolean;
      function Get_Result return Sum_Of_Cubes_Record;
   private
      Ptr_Index : Ptr_Index_Record := new Index_Record'(I => 0);
      Ptr_Result : Ptr_Sum_Of_Cubes_Record;
   end Compute_Master;

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


   -- The task which is used for parallelization of the computation of the
   -- sum of three cubes.
   task type Compute_Task (N : Positive) is
      entry Wait_For_Termination;
   end Compute_Task;
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


   -- Computes the sum of cubes of the given N using the given number of
   -- tasks and returns a record containing the result.
   function Compute_Sum_Of_Cubes(N : Positive; Num_Of_Tasks : Positive) return Sum_Of_Cubes_Record is
      Result : Sum_Of_Cubes_Record;
      procedure Multi_Task_Compute is
         Compute_Task_Array : array (0..Num_Of_Tasks) of Compute_Task(N);
      begin
         select
            delay T;
            for J in Compute_Task_Array'Range loop
               abort Compute_Task_Array(J);
            end loop;
         then abort
            for J in Compute_Task_Array'Range loop
               Compute_Task_Array(J).Wait_For_Termination;
            end loop;
         end select;
      end Multi_Task_Compute;
   begin
      Multi_Task_Compute;
      if Compute_Master.Has_Result then
         Result := Compute_Master.Get_Result;
      end if;
      Compute_Master.Reset;
      return Result;
   end Compute_Sum_Of_Cubes;


   -- Prints the computational result of one N. This procedure applies
   -- certain beautifications.
   procedure Print_Computation_Result(Result : Sum_Of_Cubes_Record; N : Positive) is
      AS : String := Long_Long_Integer'Image(Result.A);
      BS : String := Long_Long_Integer'Image(Result.B);
      CS : String := Long_Long_Integer'Image(Result.C);
   begin
      Put("  ");
      if Result.A /= 0 and Result.B /= 0 and Result.C /= 0 then
         Put(Positive'Image(N) & " =");
         Put((if Result.A < 0 then " (" & AS & ")" else AS) & "^3 +");
         Put((if Result.B < 0 then " (" & BS & ")" else BS) & "^3 +");
         Put((if Result.C < 0 then " (" & CS & ")" else CS) & "^3");
      else
         Put(Positive'Image(N) & ": Computation takes too long - Aborted!");
      end if;
      Put_Line("");
   end Print_Computation_Result;


begin


   R := (if Argument_Count > 0 then Positive'Value(Argument(1)) else R);
   K := (if Argument_Count > 1 then Positive'Value(Argument(2)) else K);
   T := (if Argument_Count > 2 then Duration'Value(Argument(3)) else T);

   Put_Line("Starting 'Sum of Cubes'");
   if Argument_Count <= 0 then
      Put_Line("  - No program parameters provided, using fallback options");
   end if;
   Put_Line("  - Find solutions for n = 1, ...," & Positive'Image(R));
   Put_Line("  - Using" & Positive'Image(K) & " tasks");
   Put_Line("  - With" & Duration'Image(T) & "s timeout");
   Put_Line("");
   Put_Line("Results: ");


   -- This block iterates through all N in a single threaded sequential order.
   for N in 1..R loop

      -- REQ2: Which for k >= 0 and neither has the form 9k+4 nor 9k+5
      if (N mod 9) /= 4 and (N mod 9) /= 5 then
         Print_Computation_Result(Compute_Sum_Of_Cubes(N, K), N);
      end if;

   end loop;

   Put_Line("");
   Put_Line("Program runtime was " & Duration'Image(Clock - Program_Start_Time) & " seconds");
   Put_Line("Thank you for using 'Sum of Cubes' <3");
   Put_Line("");
end Main;



