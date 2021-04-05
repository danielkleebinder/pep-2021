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
   R : Integer := 33;
   K : Integer := 6;


   -- Return record for the sum of cubes containing three distinct components
   -- in their base form (A³ + B³ + C³ is the result).
   type Sum_Of_Cubes_Record is
      record
         A, B, C : Long_Long_Integer := 0;
      end record;


   -- The task which is used for parallelization of the computation of the
   -- sum of three cubes.
   task type Compute_Task (N : Integer) is
      entry Check(From : in Long_Long_Integer; To : in Long_Long_Integer);
   end Compute_Task;
   task body Compute_Task is
      Dim, Dim_Squared : Long_Long_Integer := 0;
      Aq, Bq, Cq : Long_Long_Integer := 0;
      LLN : Long_Long_Integer := Long_Long_Integer(N);
      Ptr_Result : access Sum_Of_Cubes_Record;
   begin
      loop

         select
            accept Check(From : in Long_Long_Integer; To : in Long_Long_Integer) do

               Put_Line("  Start check from" & Long_Long_Integer'Image(From) & " to" & Long_Long_Integer'Image(To));

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

                  for B in From..To loop

                     Bq := B**3;

                     for C in From..To loop

                        Cq := C**3;

                        if Aq + Bq + Cq = LLN then
                           Ptr_Result := new Sum_Of_Cubes_Record'(A, B, C);
                        elsif Aq + Bq - Cq = LLN then
                           Ptr_Result := new Sum_Of_Cubes_Record'(A, B, -C);
                        elsif Aq - Bq - Cq = LLN then
                           Ptr_Result := new Sum_Of_Cubes_Record'(A, -B, -C);
                        elsif Aq - Bq + Cq = LLN then
                           Ptr_Result := new Sum_Of_Cubes_Record'(A, -B, C);
                        end if;

                        if Ptr_Result /= null then

                           Put_Line("  Found results for:"
                                    & Integer'Image(N) & " = ("
                                    & Long_Long_Integer'Image(Ptr_Result.A) & ")³ + ("
                                    & Long_Long_Integer'Image(Ptr_Result.B) & ")³ + ("
                                    & Long_Long_Integer'Image(Ptr_Result.C) & ")³");
                           Ptr_Result := null;
                           exit;
                        end if;

                     end loop;
                  end loop;
               end loop;


               Put_Line("  Check done");
            end Check;
         or
            terminate;
         end select;
      end loop;
   end Compute_Task;


   -- Computes the sum of cubes of the given N using the given number of
   -- tasks and returns a record containing the result.
   function Compute_Sum_Of_Cubes(N : in Integer; Num_Of_Tasks: in Integer) return Sum_Of_Cubes_Record is
      Compute_Task_Array : array(0..Num_Of_Tasks) of Compute_Task(N);
      Step_Size : constant Long_Long_Integer := 1_000;
      Counter : Long_Long_Integer := 1;
      I : Integer := 0;
   begin
      loop
         Put_Line("Task Index:" & Integer'Image(I mod Num_Of_Tasks));
         select
            Compute_Task_Array(I mod Num_Of_Tasks).Check(Counter, Counter + Step_Size);
            I := I + 1;
            Counter := Counter + Step_Size;
         else
            null;
         end select;
         exit when I > 10;
      end loop;
      return (1, Long_Long_Integer(N), Long_Long_Integer'Last);
   end Compute_Sum_Of_Cubes;


begin
   Put_Line("Starting cube of sums");
   Put_Line("  - Find solutions for n = 1, ...," & Integer'Image(R));
   Put_Line("  - Using" & Integer'Image(K) & " tasks");
   Put_Line("  - Integer size   :" & Integer'Image(Integer'Last));
   Put_Line("  - L Integer size :" & Long_Integer'Image(Long_Integer'Last));
   Put_Line("  - LL Integer size:" & Long_Long_Integer'Image(Long_Long_Integer'Last));


   -- This block iterates through all N in a single threaded sequential order.
   declare
      Result : Sum_Of_Cubes_Record;
   begin
      for N in 2..R loop
         if (N mod 9) /= 4 and (N mod 9) /= 5 then

            Result := Compute_Sum_Of_Cubes(N, K);

            Put_Line("Found results for:"
                     & Integer'Image(N) & " = ("
                     & Long_Long_Integer'Image(Result.A) & ")³ + ("
                     & Long_Long_Integer'Image(Result.B) & ")³ + ("
                     & Long_Long_Integer'Image(Result.C) & ")³");

         end if;
      end loop;
   end;
end Main;






