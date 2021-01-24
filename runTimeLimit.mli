(**
    [RunTimeLimit] is used to run a function thunk within a time limit, using OCaml's Unix timers and signal handling,
    which only allows this program to be compatible on Unix-based devices
    
    This program also does not work with multithreading and only supports compilation with bytecode
    
    Thanks to {{:https://tinyurl.com/yy3wdqxp} Gerd} for the method of keeping the original signal handler behavior
    
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
    [TimeLimitExceeded] is raised if the provided thunk takes longer to execute than the provided time, taking in a
    string in the form "Time limit exceeded of <time> seconds" where <time> is replaced with the provided time limit
*)
exception TimeLimitExceeded of string

(**
    [with_time_limit] runs [fn_thunk] for [time] seconds, returning the value returned by the execution of [fn_thunk] if
    it runs within the time limit and raising {!TimeLimitExceeded} otherwise
    @param timer    The {{:https://tinyurl.com/ocaml-unix-interval-timer} Unix.interval_timer} to use for setting a
                    time limit on the execution time of [fn_thunk]
    @param time     The time limit to execute [fn_thunk] in seconds
    @param fn_thunk The thunk to execute with a limit
    @return The value returned by the execution of [fn_thunk]
    @raise TimeLimitExceeded Raised if [fn_thunk] did not run within the provided time limit
*)
val with_time_limit: Unix.interval_timer -> float -> (unit -> 'a) -> 'a
