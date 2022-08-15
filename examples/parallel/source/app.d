import std.stdio;
import std.range;
import std.parallelism;
import std.random;
import std.datetime.stopwatch;
import xoshiro.xoshiro;

void main()
{
	Xoshiro128PlusPlus initGen;
	initGen.seed = unpredictableSeed;

	// initialize rndGen for each worker
	// workerLocalStorage param is lazy. it means (jump() -> save()) -> (jump() -> save()) -> ...
	auto rndGens = taskPool.workerLocalStorage(initGen.saveAfterJump());

	auto counts = taskPool.workerLocalStorage(new size_t[10]);

	auto sw = StopWatch(AutoStart.yes);
	foreach (i; parallel(iota(100_000_000)))
	{
		auto buf = counts.get();
		// const index = uniform(0, buf.length);
		const index = uniform(0, buf.length, rndGens.get());
		buf[index]++;
	}

	size_t[10] results;
	foreach (temp; counts.toRange())
	{
		results[] += temp[];
	}
	sw.stop();

	writeln(sw.peek());
	writeln(results);
}
