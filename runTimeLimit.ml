exception TimeLimitExceeded

(**
    [ThreadInterrupted] is the exception used to interrupt a thread
*)
exception ThreadInterrupted

(**
    [result] is used to store the result of trying to execute the provided
    thunk within the given time limit, having [Res] if a result was returned
    before the time limit is over and [TimeExceeded] otherwise
*)
type 'a result =
    | Res of 'a
    | TimeExceeded

(**
    [result_timer_checker] checks [res_ref] for a value every [check_freq]
    seconds, returning when [res_ref] uses the [Some] type constructor
    @param guard        The mutual-exclusion lock used to prevent concurrent accesses to [res_ref]
    @param check_period The period between each check of [res_ref]
    @param res_ref      The reference to the result of attempting to execute the provided thunk within the time limit
    @return The result of attempting to execute the provided thunk within the time limit
*)
let rec result_timer_checker (guard: Mutex.t) (check_period: float) (res_ref: 'a result option ref): 'a result =
    (* Sleep for check_freq seconds *)
    Thread.delay check_period;
    (* If res_ref's value uses the [Some] type constructor, return the value; else, continue checking *)
    Mutex.lock guard;
    match !res_ref with
        | None ->
            Mutex.unlock guard;
            result_timer_checker guard check_period res_ref
        | Some res ->
            Mutex.unlock guard;
            res

(**
    [timer] sets [res_ref] to {!TimeExceeded} if it has not been set within the time limit
    @param guard    The mutual-exclusion lock used to prevent concurrent accesses to [res_ref]
    @param time     The time limit provided for the thunk to execute
    @param res_ref  The reference to the result of attempting to execute the provided thunk within the time limit
    @param ()       Unit
    @return         Unit
*)
let timer (guard: Mutex.t) (time: int) (res_ref: 'a result option ref) (): unit =
    try
        (*
            The purpose of this loop (as opposed to using Thread.delay with the whole time) is to allow the timer thread
            to be interrupted within 0.25 seconds of fun_thunk returning if it returns before the provided time limit
        *)
        let rec delay_loop (i: int): unit =
            if i < 4 * time
            then let () = Thread.delay 0.25 in delay_loop (i + 1)
        in delay_loop 0;
        Mutex.lock guard;
        (*
            If res_ref's value does not use the [Some] type constructor when the time is up, then set it to
            TimeExceeded; else do nothing
        *)
        (match !res_ref with
            | None -> res_ref := Some TimeExceeded; Mutex.unlock guard
            | Some _ -> Mutex.unlock guard
        )
    with ThreadInterrupted -> ()

(**
    [worker] executes the provided thunk, and if it returns before the time limit, sets the result reference to the
    result of the provided thunk
    @param guard    The mutual-exclusion lock used to prevent concurrent accesses to [res_ref]
    @param fn_thunk The thunk to execute
    @param res_ref  The reference to the result of attempting to execute the provided thunk within the time limit
    @param ()       Unit
    @return         Unit
*)
let worker (guard: Mutex.t) (fn_thunk: unit -> 'a) (res_ref: 'a result option ref) (): unit =
    try
        let res = fn_thunk () in
        Mutex.lock guard;
        (*
            If res_ref has not already been set (to [TimeExceeded]), then set its value to the result of the function
            thunk's execution; else do nothing
        *)
        (match !res_ref with
            | None -> res_ref := Some (Res res)
            | Some _ -> ()
        );
        Mutex.unlock guard
    with ThreadInterrupted -> ()

(**
    [vt_signal] is the OS-appropriate signal on which a signal handler will be added to interrupt the thread if its ID
    is equivalent to {!interrupt_id}'s value
*)
let vt_signal = match Sys.os_type with
    | "Win32" -> Sys.sigterm (* Why Windows uses SIGTERM for this, I will never know *)
    | _ -> Sys.sigvtalrm

(**
    [interrupt_id] is the reference to the unique identifier of the thread to interrupt
*)
let interrupt_id = ref None

(**
    [interrupt] forcefully interrupts the current thread if its ID is equivalent to the ID stored in {!interrupt_id}; it
    also continues with the original signal handler action
    @param vt_original_behavior_ref The reference to the original behavior associated with {!vt_signal}
    @param sig_num                  The signal number this signal handler was called with
    @return Unit
    @raise [ThreadInterrupted] Raised if the current thread's ID is equivalent to the ID stored in {!interrupt_id}
*)
let interrupt (vt_original_behavior_ref: Sys.signal_behavior ref) (sig_num: int): unit =
    if Some(Thread.id (Thread.self ())) = !interrupt_id
    then raise ThreadInterrupted;
    match !vt_original_behavior_ref with
        | Sys.Signal_handle f -> f sig_num
        | _ -> failwith "The Threads library must be enabled to use RunTimeLimit"

let with_time_limit (time: int) (check_period: float) (fn_thunk: unit -> 'a): 'a =
    (* The mutual-exclusion lock used to prevent concurrent accesses to res_ref *)
    let guard = Mutex.create () in
    (* The reference to the result of attempting to execute the provided thunk within the time limit *)
    let res_ref = ref None in
    (*
        vt_original_behavior_ref is made to contain the original behavior/action originally associated with vt_signal,
        using some reference shenanigans to pass this original behavior to the new signal handler function interrupt
    *)
    let vt_original_behavior_ref = ref Sys.Signal_ignore in
    let vt_original_behavior = Sys.signal vt_signal (Sys.Signal_handle (interrupt vt_original_behavior_ref)) in
    vt_original_behavior_ref := vt_original_behavior;
    (* Creates and starts the threads for the timer and worker *)
    let timer_thread = Thread.create (timer guard time res_ref) () in
    let worker_thread = Thread.create (worker guard fn_thunk res_ref) () in
    (* Checks for res_ref being assigned every check_period seconds and returns its value when it is *)
    let result = result_timer_checker guard check_period res_ref in
    match result with
        (* If a result was returned by the function, then interrupt the timer thread and return the result *)
        | Res res ->
            interrupt_id := Some (Thread.id timer_thread);
            Thread.join timer_thread;
            res
        (* If the time limit was exceeded, then interrupt the worker thread and raise TimeLimitExceeded *)
        | TimeExceeded ->
            interrupt_id := Some (Thread.id worker_thread);
            Thread.join worker_thread;
            raise TimeLimitExceeded
