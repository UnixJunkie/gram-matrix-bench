
(* Compute a Gram matrix as fast as possible using parallelization *)

open Printf

module A = Array
module CLI = Minicli.CLI
module L = List
module Log = Dolog.Log

let dot_product xs ys =
  let n = A.length xs in
  assert(n = A.length ys);
  let res = ref 0.0 in
  for i = 0 to n - 1 do
    res := !res +. ((A.unsafe_get xs i) *. (A.unsafe_get ys i))
  done;
  !res

type style = Sequential
           | Par_Parmap
           | Par_Parany
           | Par_Multicore

let string_of_style = function
  | Sequential -> "seq"
  | Par_Parmap -> "parmap"
  | Par_Parany -> "parany"
  | Par_Multicore -> "multicore"

let emit_one (i: int ref) (n: int) ((): unit): int =
  if !i >= n then raise Parany.End_of_input
  else
    let res = !i in
    incr i;
    res

let process_one (samples: float array array) (n: int) (i: int):
  (int * float list) =
  let js = Utls.range i (n - 1) in
  let si = samples.(i) in
  (i, L.map (fun j -> dot_product si samples.(j)) js)

let gather_one (res: float array array) ((i, xs): (int * float list)): unit =
  L.iteri (fun j' x ->
      let j = j' + i in
      res.(i).(j) <- x;
      res.(j).(i) <- x (* symmetric matrix *)
    ) xs

let compute_gram_matrix style ncores chunksize samples =
  let n = A.length samples in
  assert(n > 0);
  match style with
  | Sequential -> (* ------------------------------------------------------- *)
    let res = A.init n (fun _ -> A.create_float n) in
    for i = 0 to n - 1 do
      for j = i to n - 1 do
        let x = dot_product samples.(i) samples.(j) in
        res.(i).(j) <- x;
        res.(j).(i) <- x (* symmetric matrix *)
      done
    done;
    res
  | Par_Parmap -> (* ------------------------------------------------------- *)
    let is = Utls.range 0 (n - 1) in
    let dots =
      let () = Parmap.enable_core_pinning () in
      Parmap.parmap ~ncores ~chunksize (fun i ->
          let js = Utls.range i (n - 1) in
          L.map (fun j ->
              (i, j, dot_product samples.(i) samples.(j))
            ) js
        ) (Parmap.L is) in
    let res = A.init n (fun _ -> A.create_float n) in
    L.iter (
      L.iter (fun (i, j, x) ->
          res.(i).(j) <- x;
          res.(j).(i) <- x (* symmetric matrix *)
        )
    ) dots;
    res
  | Par_Parany -> (* ------------------------------------------------------- *)
    let res = A.init n (fun _ -> A.create_float n) in
    let () = Parany.enable_core_pinning () in
    Parany.run ~verbose:false ~csize:chunksize ~nprocs:ncores
      ~demux:(emit_one (ref 0) n)
      ~work:(process_one samples n)
      ~mux:(gather_one res);
    res
  | Par_Multicore -> (* ---------------------------------------------------- *)
    failwith "Multicore: not implemented yet"

let parse_line line =
  let int_strings = Utls.string_split_on_char ' ' line in
  let nb_features = L.length int_strings in
  let res = A.create_float nb_features in
  L.iteri (fun i int_str ->
      A.unsafe_set res i (float_of_string int_str)
    ) int_strings;
  res

(* print matrix corners *)
let print_matrix mat =
  let m = A.length mat in
  let n = A.length mat.(0) in
  let idots = ref false in
  for i = 0 to m - 1 do
    if i < 3 || i > m - 4 then
      begin
        let jdots = ref false in
        for j = 0 to n - 1 do
          if j < 3 || j > n - 4 then
            printf (if j <> 0 then "\t%6.2f" else "%6.2f")
              mat.(i).(j)
          else if not !jdots then
            (printf "\t..."; jdots := true)
        done;
        printf "\n"
      end
    else if not !idots then
      (printf "\t\t\t...\n"; idots := true)
  done;
  flush stdout

let main () =
  Log.color_on ();
  Log.set_log_level Log.INFO;
  let argc, args = CLI.init () in
  let show_help = CLI.get_set_bool ["-h";"--help"] args in
  if argc = 1 || show_help then
    (eprintf "usage:\n\
              %s -i <data.csv>\n  \
              [-h|--help]: show this help message\n  \
              [-np <int>]: nprocs\n  \
              [-c <int>]: chunk size\n  \
              [-q]: quiet mode\n"
       Sys.argv.(0);
     exit 1);
  let input_fn = CLI.get_string ["-i"] args in
  let ncores = CLI.get_int_def ["-np"] args 1 in
  let csize = CLI.get_int_def ["-c"] args 1 in
  let quiet = CLI.get_set_bool ["-q"] args in
  CLI.finalize ();
  (* read data in *)
  let samples = A.of_list (Utls.map_on_lines_of_file input_fn parse_line) in
  if not quiet then
    Log.info "samples: %d features: %d"
      (A.length samples) (A.length samples.(0));
  let ref_dt, ref_matrix =
    Gc.full_major ();
    Utls.wall_clock_time (fun () ->
        compute_gram_matrix Sequential 1 1 samples
      ) in
  if not quiet then print_matrix ref_matrix;
  Log.info "n: %d c: %d s: %s dt: %.2f a: %.2f"
    ncores csize "seq" ref_dt 1.0;
  L.iter (fun style ->
      let () = Gc.full_major () in
      let curr_dt, curr_matrix =
        Utls.wall_clock_time (fun () ->
            compute_gram_matrix style ncores csize samples
          ) in
      let style_name = string_of_style style in
      Utls.enforce (curr_matrix = ref_matrix)
        (style_name ^ ": matrix <> ref_matrix");
      Log.info "n: %d c: %d s: %s dt: %.2f a: %.2f"
        ncores csize style_name curr_dt (ref_dt /. curr_dt)
    ) [Par_Parmap; Par_Parany];
    (* ) [Par_Parmap; Par_Parany; Par_Multicore]; *)
  ()

let () = main ()
