/**
 *xoshiro generators
 *Authors: lempiji
 */
module xoshiro.xoshiro;

import xoshiro.util;

import std.random;

///
enum XoshiroOpMode
{
    Plus,
    PlusPlus,
    StarStar,
}

///
struct XoshiroEngine(UIntType, XoshiroOpMode mode)
{
    static assert(is(UIntType == uint) || is(UIntType == ulong));

    enum isUniformRandom = true;
    enum min = UIntType(0);
    enum max = UIntType.max;

private:
    UIntType[4] state;

    enum shiftSize = UIntType.sizeof == 8 ? 17 : 9;
    enum rotSize = UIntType.sizeof == 8 ? 45 : 11;
    enum UIntBits = UIntType.sizeof * 8;

public:
    ///
    this()()
    {
        this.seed = 0;
    }

    ///
    this()(UIntType seed)
    {
        this.seed = seed;
    }

    ///
    enum empty = false;

    ///
    UIntType front() const pure nothrow @safe @nogc @property
    {
        static if (mode == XoshiroOpMode.Plus)
            return state[0] + state[3];
        else static if (mode == XoshiroOpMode.PlusPlus)
            return rotl(state[0] + state[3], 23) + state[0];
        else static if (mode == XoshiroOpMode.StarStar)
            return rotl(state[1] * 5, 7) * 9;
        else
            static assert(false);
    }

    ///
    void popFront() @safe pure nothrow @nogc
    {
        const UIntType t = state[1] << shiftSize;

        state[2] ^= state[0];
        state[3] ^= state[1];
        state[1] ^= state[2];
        state[0] ^= state[3];

        state[2] ^= t;

        state[3] = rotl(state[3], rotSize);
    }

    ///
    typeof(this) save() const @safe pure nothrow @nogc
    {
        return this;
    }

    /// jump() -> save()
    typeof(this) saveAfterJump() @safe pure nothrow @nogc
    {
        jump();
        return this;
    }

    /// longJump() -> save()
    typeof(this) saveAfterLongJump() @safe pure nothrow @nogc
    {
        longJump();
        return this;
    }

    ///
    void seed(UIntType seed) @safe pure nothrow @nogc
    {
        ulong temp = seed;
        state[0] = cast(UIntType) splitMix(temp);
        state[1] = cast(UIntType) splitMix(temp);
        state[2] = cast(UIntType) splitMix(temp);
        state[3] = cast(UIntType) splitMix(temp);
    }

    ///It is equivalent to 2^N calls to popFront()
    ///
    /// N = 128 on Xoshiro256  
    /// N =  64 on Xoshiro128
    void jump()
    {
        static if (UIntType.sizeof == 8)
        {
            // 256
            enum ulong[] JUMP = [
                    0x180ec6d33cfd0aba, 0xd5a61266f0c9392c, 0xa9582618e03fc9aa,
                    0x39abdc4529b1661c
                ];
        }
        else
        {
            // 128
            enum uint[] JUMP = [
                    0x8764000b, 0xf542d2d3, 0x6fa035c3, 0x77f2db5b
                ];
        }

        UIntType s0 = 0;
        UIntType s1 = 0;
        UIntType s2 = 0;
        UIntType s3 = 0;
        foreach (jump; JUMP)
        {
            foreach (b; 0 .. UIntBits)
            {
                if (jump & (UIntType(1) << b))
                {
                    s0 ^= state[0];
                    s1 ^= state[1];
                    s2 ^= state[2];
                    s3 ^= state[3];
                }
                popFront();
            }
        }

        state[0] = s0;
        state[1] = s1;
        state[2] = s2;
        state[3] = s3;
    }

    ///It is equivalent to 2^N calls to popFront()
    ///
    /// N = 192 on Xoshiro256  
    /// N =  96 on Xoshiro128
    void longJump()
    {
        static if (UIntType.sizeof == 8)
        {
            // 256
            enum ulong[] LONG_JUMP = [
                    0x76e15d3efefdcbbf, 0xc5004e441c522fb3, 0x77710069854ee241,
                    0x39109bb02acbe635
                ];
        }
        else
        {
            // 128
            enum uint[] LONG_JUMP = [
                    0xb523952e, 0x0b6f099f, 0xccf5a0ef, 0x1c580662
                ];
        }
        UIntType s0 = 0;
        UIntType s1 = 0;
        UIntType s2 = 0;
        UIntType s3 = 0;
        foreach (jump; LONG_JUMP)
        {
            foreach (b; 0 .. UIntBits)
            {
                if (jump & (UIntType(1) << b))
                {
                    s0 ^= state[0];
                    s1 ^= state[1];
                    s2 ^= state[2];
                    s3 ^= state[3];
                }
                popFront();
            }
        }
        state[0] = s0;
        state[1] = s1;
        state[2] = s2;
        state[3] = s3;
    }
}

/**
 * Xoshiro256+
 * Period: 2 ^ 256 - 1
 * Footprint: 32 bytes
 */
alias Xoshiro256Plus = XoshiroEngine!(ulong, XoshiroOpMode.Plus);

/// ditto
@("Overview Xoshiro256+")
unittest
{
    import std.random : uniform01;

    auto rndGen = Xoshiro256Plus(unpredictableSeed!ulong);
    auto x = uniform01(rndGen);
    assert(0 <= x && x <= 1);
}

/**
 * Xoshiro256++
 * Period: 2 ^ 256 - 1
 * Footprint: 32 bytes
 */
alias Xoshiro256PlusPlus = XoshiroEngine!(ulong, XoshiroOpMode.PlusPlus);

/// ditto
@("Overview Xoshiro256++")
unittest
{
    import std.random : uniform01;

    auto rndGen = Xoshiro256PlusPlus(unpredictableSeed!ulong);
    auto x = uniform01(rndGen);
    assert(0 <= x && x <= 1);
}

/**
 * Xoshiro256**
 * Period: 2 ^ 256 - 1
 * Footprint: 32 bytes
 */
alias Xoshiro256StarStar = XoshiroEngine!(ulong, XoshiroOpMode.StarStar);

/// ditto
@("Overview Xoshiro256**")
unittest
{
    import std.random : uniform01;

    auto rndGen = Xoshiro256StarStar(unpredictableSeed!ulong);
    auto x = uniform01(rndGen);
    assert(0 <= x && x <= 1);
}

/**
 * Xoshiro128+
 * Period: 2 ^ 128 - 1
 * Footprint: 16 bytes
 */
alias Xoshiro128Plus = XoshiroEngine!(uint, XoshiroOpMode.Plus);

/// ditto
@("Overview Xoshiro128+")
unittest
{
    import std.random : uniform01;

    auto rndGen = Xoshiro128Plus(unpredictableSeed);
    auto x = uniform01(rndGen);
    assert(0 <= x && x <= 1);
}

/**
 * Xoshiro128++
 * Period: 2 ^ 128 - 1
 * Footprint: 16 bytes
 */
alias Xoshiro128PlusPlus = XoshiroEngine!(uint, XoshiroOpMode.PlusPlus);

/// ditto
@("Overview Xoshiro128++")
unittest
{
    import std.random : uniform01;

    auto rndGen = Xoshiro128PlusPlus(unpredictableSeed);
    auto x = uniform01(rndGen);
    assert(0 <= x && x <= 1);
}

/**
 * Xoshiro128**
 * Period: 2 ^ 128 - 1
 * Footprint: 16 bytes
 */
alias Xoshiro128StarStar = XoshiroEngine!(uint, XoshiroOpMode.StarStar);

/// ditto
@("Overview Xoshiro128**")
unittest
{
    import std.random : uniform01;

    auto rndGen = Xoshiro128StarStar(unpredictableSeed);
    auto x = uniform01(rndGen);
    assert(0 <= x && x <= 1);
}

@("isInfinityForwardRange && isUniformRNG && isSeedable")
unittest
{
    import std.range;
    import std.meta : AliasSeq;

    alias Ts = AliasSeq!(
        Xoshiro128Plus, Xoshiro128PlusPlus, Xoshiro128StarStar,
        Xoshiro256Plus, Xoshiro256PlusPlus, Xoshiro256StarStar);

    static foreach (T; Ts)
    {
        static assert(isInfinite!T);
        static assert(isForwardRange!T);
        static assert(isUniformRNG!T);
        static assert(isSeedable!(T, ElementType!T));
    }
}
