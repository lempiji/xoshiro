module xoshiro.util;

pragma(inline, true)
uint rotl(uint v, byte s) pure nothrow @nogc @safe
{
    return (v << s) | (v >> (32 - s));
}

pragma(inline, true)
ulong rotl(ulong x, byte s) pure nothrow @nogc @safe
{
    return (x << s) | (x >> (64 - s));
}

ulong splitMix(ref ulong x) pure nothrow @safe @nogc
{
    x += 0x9E3779B97F4A7C15;
    ulong z = x;
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EB;
    z = z ^ (z >> 31);
    return z;
}
