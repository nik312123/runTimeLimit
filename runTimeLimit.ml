(* 
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

exception TimeLimitExceeded of string

(**
    [AlarmOccurred] is the exception raised by the new alarm signal handler for the alarm set using
    {{:https://tinyurl.com/ocaml-unix-interval-timer} Unix.setitimer}
*)
exception AlarmOccurred

(**
    [interrupt] is the alarm signal handler used to call the original alarm signal handler and raise {!AlarmOccurred} to
    stop the currently-executing [fn_thunk] in {!with_time_limit}
    @param original_alarm_behavior_ref The reference to the original behavior associated with the signal associated with
                                       the {{:https://tinyurl.com/ocaml-unix-interval-timer} Unix.interval_timer}
                                       that was provided to {!with_time_limit}
    @param sig_num                     The signal number this signal handler was called with
    @return Unit
    @raise [AlarmOccurred] Always raised as long as the original alarm signal handler does not raise any exceptions
*)
let interrupt (original_alarm_behavior_ref: Sys.signal_behavior ref) (sig_num: int): unit =
    (match !original_alarm_behavior_ref with
        | Sys.Signal_handle original_alarm_behavior -> original_alarm_behavior sig_num
        | _ -> ());
    raise AlarmOccurred

let with_time_limit (timer: Unix.interval_timer) (time: float) (fn_thunk: unit -> 'a): 'a =
    if time = 0. then raise (TimeLimitExceeded (Printf.sprintf "Time limit exceeded of %f seconds" time));
    (*
        original_alarm_behavior_ref is made to contain the original behavior/action originally associated with signal,
        using some reference shenanigans to pass this original behavior to the new signal handler function interrupt
    *)
    let signal = (match timer with
        | Unix.ITIMER_REAL -> Sys.sigalrm
        | Unix.ITIMER_VIRTUAL -> Sys.sigvtalrm
        | Unix.ITIMER_PROF -> Sys.sigprof
    )
    in let original_alarm_behavior_ref = ref Sys.Signal_ignore in
    let original_alarm_behavior = Sys.signal signal (Sys.Signal_handle (interrupt original_alarm_behavior_ref)) in
    original_alarm_behavior_ref := original_alarm_behavior;
    (* Starts the Unix timer for the provided amount of time *)
    let _ = Unix.setitimer timer { Unix.it_interval = 0.; Unix.it_value = time } in
    (*
        Executes and returns the result of [fn_thunk] if it completes within the provided time limit, raising
        TimeLimitExceeded otherwise
    *)
    try fn_thunk ()
    with AlarmOccurred -> raise (
        TimeLimitExceeded (Printf.sprintf "Time limit exceeded of %f seconds" time)
    )
