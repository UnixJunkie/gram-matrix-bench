
(* Compute a Gram matrix as fast as possible using parallelism *)

module A = BatArray
module L = BatList
module Log = Dolog.Log

let dot_product xs ys =
  let res = ref 0.0 in
  A.iter2 (fun x y ->
      res := !res +. (x *. y)
    ) xs ys;
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

let compute_gram_matrix style nb_features samples =
  match style with
  | Sequential ->
    let n = A.length samples in
    let res = A.init n (fun _ -> A.make nb_features 0.0) in
    for i = 0 to n - 1 do
      for j = i to n - 1 do
        let x = dot_product samples.(i) samples.(j) in
        res.(i).(j) <- x;
        res.(j).(i) <- x
      done
    done;
    res
  | _ -> assert(false)

let compute_gram_matrix_paramp () =
  failwith "not implemented yet"

let compute_gram_matrix_parany () =
  failwith "not implemented yet"

let compute_gram_matrix_multicore () =
  failwith "waiting for external contribution"

let compute_nb_features_max () =
  failwith "not implemented yet"

let read_one_line _line =
  failwith "not implemented yet"

let main () =
  (* read data in *)
  let _ncores = 1 in
  let _csize = 1 in
  let nb_features = failwith "not implemented yet" in
  let samples = failwith "not implemented yet" in
  let ref_dt, ref_matrix =
    Gc.full_major ();
    Utls.wall_clock_time (fun () ->
        compute_gram_matrix Sequential nb_features samples
      ) in
  (* TODO: print corners of the ref matrix *)
  L.iter (fun style ->
      let () = Gc.full_major () in
      let curr_dt, curr_matrix =
        Utls.wall_clock_time (fun () ->
            compute_gram_matrix style nb_features samples
          ) in
      let style_name = string_of_style style in
      Utls.enforce (curr_matrix = ref_matrix)
        (style_name ^ ": matrix <> ref_matrix");
      Log.info "style: %s dt: %f accel: %.2f"
        style_name curr_dt (ref_dt /. curr_dt)
    ) [Par_Parmap; Par_Parany; Par_Multicore];
  ()

let () = main ()
