------------------------------------------
--                                      --
--   Parallel and Real-Time Computing   --
--                                      --
--             Exercise 1               --
--                                      --
--          Daniel Kleebinder           --
--                                      --
------------------------------------------

with Ada.Text_IO, Ada.Command_Line;
use Ada.Text_IO, Ada.Command_Line;



procedure Main is
   R : Integer := 29;
   K : Integer := 6;


   -- Return record for the sum of cubes containing three distinct components
   -- in their base form (A³ + B³ + C³ is the result).
   type Sum_Of_Cubes_Record is
      record
         A, B, C : Long_Long_Integer := 0;
      end record;
   type Ptr_Sum_Of_Cubes_Record is access Sum_Of_Cubes_Record;


   -- The compute master is used to accumulate results and inform the tasks
   -- that a result was already found.
   protected Compute_Master is
      procedure Set_Result(Result : Ptr_Sum_Of_Cubes_Record);
      procedure Reset;
      function Has_Result return Boolean;
      function Get_Result return Sum_Of_Cubes_Record;
   private
      Ptr_Result : Ptr_Sum_Of_Cubes_Record;
   end Compute_Master;

   protected body Compute_Master is

      procedure Set_Result(Result : Ptr_Sum_Of_Cubes_Record) is begin Ptr_Result := Result; end Set_Result;
      procedure Reset is begin Ptr_Result := null; end Reset;

      function Has_Result return Boolean is begin return Ptr_Result /= null; end Has_Result;
      function Get_Result return Sum_Of_Cubes_Record is begin return Ptr_Result.all; end Get_Result;

   end Compute_Master;


   -- The task which is used for parallelization of the computation of the
   -- sum of three cubes.
   task type Compute_Task (N : Integer) is
      entry Check(From : Long_Long_Integer; To : Long_Long_Integer);
   end Compute_Task;
   task body Compute_Task is
      Dim, Dim_Squared : Long_Long_Integer := 0;
      Aq, Bq, Cq : Long_Long_Integer := 0;
      LLN : Long_Long_Integer := Long_Long_Integer(N);
   begin
      loop

         select
            when not Compute_Master.Has_Result =>
               accept Check(From : Long_Long_Integer; To : Long_Long_Integer) do

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
                  Outer_Loop:
                  for A in From..To loop
                     Aq := A**3;

                     for B in From..To loop
                        Bq := B**3;

                        for C in From..To loop
                           Cq := C**3;

                           -- I put this before the if block because I do not want
                           -- other tasks to overwrite the result of another task
                           exit Outer_Loop when Compute_Master.Has_Result;

                           -- Test for all combinations if any fits the sum of cubes
                           if Aq + Bq + Cq = LLN then
                              Compute_Master.Set_Result(new Sum_Of_Cubes_Record'(A, B, C));
                           elsif Aq + Bq - Cq = LLN then
                              Compute_Master.Set_Result(new Sum_Of_Cubes_Record'(A, B, -C));
                           elsif Aq - Bq - Cq = LLN then
                              Compute_Master.Set_Result(new Sum_Of_Cubes_Record'(A, -B, -C));
                           elsif Aq - Bq + Cq = LLN then
                              Compute_Master.Set_Result(new Sum_Of_Cubes_Record'(A, -B, C));
                           end if;

                        end loop;
                     end loop;
                  end loop Outer_Loop;

               end Check;
         or
            terminate;
         end select;
      end loop;
   end Compute_Task;


   -- Computes the sum of cubes of the given N using the given number of
   -- tasks and returns a record containing the result.
   function Compute_Sum_Of_Cubes(N : Integer; Num_Of_Tasks : Integer) return Sum_Of_Cubes_Record is
      Compute_Task_Array : array(0..Num_Of_Tasks) of Compute_Task(N);
      Step_Size : constant Long_Long_Integer := 1_000;
      Counter : Long_Long_Integer := 1;
      I : Integer := 0;
      Result : Sum_Of_Cubes_Record;
   begin
      loop
         select
            Compute_Task_Array(I mod Num_Of_Tasks).Check(Counter, Counter + Step_Size);
         else
            null;
         end select;
         I := I + 1;
         Counter := Counter + Step_Size;
         exit when Compute_Master.Has_Result;
      end loop;
      Result := Compute_Master.Get_Result;
      Compute_Master.Reset;
      return Result;
   end Compute_Sum_Of_Cubes;


   -- Prints the computational result of one N. This procedure applies
   -- certain beautifications.
   procedure Print_Computation_Result(Result : Sum_Of_Cubes_Record; N : Integer) is
      AS : String := Long_Long_Integer'Image(Result.A);
      BS : String := Long_Long_Integer'Image(Result.B);
      CS : String := Long_Long_Integer'Image(Result.C);
   begin
      Put("  ");
      Put(Integer'Image(N) & " =");
      Put((if Result.A < 0 then " (" & AS & ")" else AS) & "³ +");
      Put((if Result.B < 0 then " (" & BS & ")" else BS) & "³ +");
      Put((if Result.C < 0 then " (" & CS & ")" else CS) & "³");
      Put_Line("");
   end Print_Computation_Result;


begin
   Put_Line("Starting 'Sum of Cubes'");
   Put_Line("  - Find solutions for n = 1, ...," & Integer'Image(R));
   Put_Line("  - Using" & Integer'Image(K) & " tasks");
   Put_Line("");
   Put_Line("Results: ");


   -- This block iterates through all N in a single threaded sequential order.
   for N in 1..R loop
      if (N mod 9) /= 4 and (N mod 9) /= 5 then
         Print_Computation_Result(Compute_Sum_Of_Cubes(N, K),N);
      end if;
   end loop;

   Put_Line("");
   Put_Line("Thank you for using 'Sum of Cubes' <3");
   Put_Line("");
end Main;



