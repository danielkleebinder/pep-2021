------------------------------------------
--                                      --
--   Parallel and Real-Time Computing   --
--                                      --
--             Exercise 1               --
--                                      --
--          Daniel Kleebinder           --
--                                      --
------------------------------------------

-- For this exercise, I will assume, that |a| <= |b| <= |c|

with Ada.Text_IO, Ada.Command_Line;
use Ada.Text_IO, Ada.Command_Line;



procedure Main is
   R : Integer := 33;
   K : Integer := 2;


   -- Return record for the sum of cubes containing three distinct components
   -- in their base form (A³ + B³ + C³ is the result).
   type Sum_Of_Cubes_Record is
      record
         A, B, C : Long_Long_Integer := 0;
      end record;


   -- The task which is used for parallelization of the computation of the
   -- sum of three cubes.
   task type Compute_Task (N : Integer;
                                        From : Long_Long_Integer;
                                        To : Long_Long_Integer);
   task body Compute_Task is
      Counter : Long_Long_Integer := 0;
      A, B, C : Long_Long_Integer := 0;
   begin
      loop

         -- Go from 1 to -1 to 2 to -2 to 3 to -3, ...
         A := (if Counter mod 2 = 0 then (-A) + 1 else -A);
         B := 0;

         for I in 0..(A*2) loop

            -- Go from 1 to -1 to 2 to -2 to 3 to -3, ...
            B := (if I mod 2 = 0 then (-B) + 1 else -B);
            C := 0;

            for J in 0..(B*2) loop

               -- Go from 1 to -1 to 2 to -2 to 3 to -3, ...
               C := (if J mod 2 = 0 then (-C) + 1 else -C);

               if (A**3 + B**3 + C**3) = Long_Long_Integer(N) then
                  goto End_Of_Task;
               end if;

            end loop;

         end loop;

         Counter := Counter + 1;
      end loop;
      <<End_Of_Task>>
   end Compute_Task;


   -- Computes the sum of cubes of the given N using the given number of
   -- tasks and returns a record containing the result.
   function Compute_Sum_Of_Cubes(N : in Integer; Num_Of_Tasks: in Integer) return Sum_Of_Cubes_Record is
      type Ptr_Compute_Task is access Compute_Task;
      type Ptr_Compute_Task_Array is array(0..Num_Of_Tasks) of Ptr_Compute_Task;
   begin
      return (1, 2, Long_Long_Integer'Last);
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
      for N in 1..R loop
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






