(**
    [RunTimeLimit] is used to run a function thunk within a time limit, using OCaml
    {{:https://tinyurl.com/ocaml-thread} Thread}s and OS-dependent signal handling
    
    Note that the time provided to [RunTimeLimit] is not very precise, so the program will often finish later than the
    provided number of seconds; the error increases proportionally with the number of seconds provided
    
    Additionally, this library has only been tested on Unix-based systems, so no guarantees are made on its usability on
    Windows
    
    Thanks to {{:https://tinyurl.com/yywosqwl} ivg}, {{:https://tinyurl.com/y68kulfw} Justin}, and
    {{:https://tinyurl.com/yy3wdqxp} Gerd} for the material used as reference when creating this module
    
    Copyright (C) 2020 Nikunj Chawla
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.
    
    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see {:https://www.gnu.org/licenses/}.
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
