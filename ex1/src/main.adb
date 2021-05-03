------------------------------------------------------------------------------
--                                                                          --
--                     Parallel and Real-Time Computing                     --
--                                                                          --
--                            E X E R C I S E  2                            --
--                                                                          --
--                                 M a i n                                  --
--                                                                          --
--                             Daniel Kleebinder                            --
--                                                                          --
-- Ada does not have something like a "Main" procedure or function, it just --
-- specifies one file (and procedure) which will be executed first when the --
-- program starts. This is what this file is about.                         --
--                                                                          --
-- This program computes the sum of cubes of certain numbers using certain  --
-- input parameters. How to use it?                                         --
--                                                                          --
-- <program> <limit> <tasks> <timeout>                                      --
--                                                                          --
-- <program> - The programs executable file                                 --
-- <limit>   - Specifies the upper limit of number to compute the sum of    --
-- <tasks>   - Specifies the number of concurrent tasks used                --
-- <timeout> - Specifies the max computation time per number                --
--                                                                          --
-- Please note that none of those parameters are actually required. All of  --
-- them do indeed have a standard default value.                            --
-- This specification is derived from the Ada Reference Manual for use with --
-- GNAT. The copyright notice above, and the license provisions that follow --
-- apply solely to the  contents of the part following the private keyword. --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Text_IO, Ada.Command_Line, Ada.Calendar, Sum_Of_Cubes;
use Ada.Text_IO, Ada.Command_Line, Ada.Calendar, Sum_Of_Cubes;


procedure Main is

   Program_Start_Time : Time := Clock;

   -- REQ1: Let n >= 1 be a natural number
   R : Positive := 40;
   K : Positive := 6;

   -- Not specifying any T on the CLI (i.e. T stays 0) means infinite computation time
   T : Duration := 2.0;


   -- Computes the sum of cubes of the given N using the given number of
   -- tasks and returns a record containing the result.
   function Compute_Sum_Of_Cubes(N : Positive; Num_Of_Tasks : Positive) return Sum_Of_Cubes_Record is
      Result : Sum_Of_Cubes_Record;
      procedure Multi_Task_Compute is
         Compute_Task_Array : array (0..Num_Of_Tasks) of Compute_Task(N);
      begin
         if T > 0.0 then
            select

               -- Delay T seconds if T is greater than 0. If this delay cannot be fulfilled
               -- abort all the tasks.
               delay T;

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



