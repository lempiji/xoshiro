module app;

import std.stdio;

import xoshiro.xoshiro;

void main()
{
	const result1 = benchmark!Xoshiro256Plus;
	const result2 = benchmark!Xoshiro256PlusPlus;
	const result3 = benchmark!Xoshiro256StarStar;
	const result4 = benchmark!Xoshiro128Plus;
	const result5 = benchmark!Xoshiro128PlusPlus;
	const result6 = benchmark!Xoshiro128StarStar;
	const result7 = benchmark!Xorshift;

	writeln(result1);
	writeln(result2);
	writeln(result3);
	writeln(result4);
	writeln(result5);
	writeln(result6);
	writeln(result7);
}

double benchmark(T, size_t epoch = 1_000_000_000)()
{
	import std.random;

	T rndGen;
	rndGen.seed = unpredictableSeed;

	import std.datetime.stopwatch;

	StopWatch sw;
	sw.start();
	scope (exit)
	{
		sw.stop();
		writeln("benchmark ", T.stringof, " : ", sw.peek());
	}

	double s = 0;
	foreach (_; 0 .. epoch)
	{
		s += uniform01(rndGen);
	}
	return s / epoch;
}