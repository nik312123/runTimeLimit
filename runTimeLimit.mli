(**
    [RunTimeLimit] is used to run a function thunk within a time limit, using OCaml
    {{:https://tinyurl.com/ocaml-thread} Thread}s and OS-dependent signal handling
    
    Note that the time provided to [RunTimeLimit] is not very precise, so the program will often finish later than the
    provided number of seconds; the error increases proportionally with the number of seconds provided
    
    Thanks to {{:https://tinyurl.com/yywosqwl} ivg}, {{:https://tinyurl.com/y68kulfw} Justin}, and
    {{:https://tinyurl.com/yy3wdqxp} Gerd} for the material used as reference when creating this module
*)

(**
    [TimeLimitExceeded] is raised if the provided thunk takes longer to execute than the provided time
*)
exception TimeLimitExceeded

(**
    [with_time_limit] runs [fn_thunk] for [time] seconds, returning the value returned by the execution of [fn_thunk] if
    it runs within the time limit and raising {!TimeLimitExceeded} otherwise; it also checks whether or not a value has
    been returned by the thread running [fn_thunk] every [check_period] seconds
    @param time         The time limit to execute [fn_thunk] in seconds
    @param check_period The period between each check of [res_ref] for the result
    @param fn_thunk     The thunk to execute with a limit
    @return The value returned by the execution of [fn_thunk]
    @raise [TimeLimitExceeded] Raised if [fn_thunk] did not run within the provided time limit
*)
val with_time_limit: int -> float -> (unit -> 'a) -> 'a
