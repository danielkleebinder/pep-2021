
package Sum_Of_Cubes is

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


   -- The task which is used for parallelization of the computation of the
   -- sum of three cubes.
   task type Compute_Task (N : Positive) is
      entry Wait_For_Termination;
   end Compute_Task;

end Sum_Of_Cubes;
