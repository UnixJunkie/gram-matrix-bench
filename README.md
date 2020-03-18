# gram-matrix-bench
Performance benchmark for Parmap, Parany and Multicore-OCaml

Cf. https://en.wikipedia.org/wiki/Gramian_matrix

Run example:

```
./gram -i data/tox21_nrar_ligands_std_rand_01.csv -np 16
2020-03-18 12:36:35.421 INFO : samples: 7026 features: 1972
 48.00   18.00    4.00  ... 16.00        15.00    8.00
 18.00   28.00    5.00  ... 24.00         8.00    7.00
  4.00    5.00   40.00  ... 12.00        28.00   38.00
                        ...
 16.00   24.00   12.00  ... 64.00        16.00   16.00
 15.00    8.00   28.00  ... 16.00        54.00   34.00
  8.00    7.00   38.00  ... 16.00        34.00   72.00
2020-03-18 12:44:06.769 INFO : n: 16 c: 1 s: seq dt: 451.34 a: 1.00
2020-03-18 12:44:53.569 INFO : n: 16 c: 1 s: parmap dt: 46.72 a: 9.66
2020-03-18 12:45:43.420 INFO : n: 16 c: 1 s: parany dt: 48.74 a: 9.26

```

I.e. with Parmap we get an acceleration factor of 9.66 when using 16 cores
and 9.26 with Parany.
