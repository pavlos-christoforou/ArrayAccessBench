ArrayAccessBench
================

Microbenchmark of array access and mutation.

Run with go run Benchmarker.go

In the Benchmarker.go source the output and input file can be changed. The numtrades values to test are stored near the top of the file in an array of strings, and the time to pause between runs can also be set via the WaitTime constant.

The input data is formatted as follows; a list of:

Language Name

Commands to compile it or '-' if interpreted

Commands to run it

The source file name

The resulting executable name or '-' if interpreted

