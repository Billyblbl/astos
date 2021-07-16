#ifndef GTYPES
# define GTYPES

#include <meta.cpp>

template<unsigned bitCount, typename First, typename... Types>
struct firstOfBitSizeHelper;

template<unsigned bitCount>
struct firstOfBitSizeHelper<bitCount, void> {
	using Type = void;
};

template<unsigned bitCount, typename First, typename... Types>
struct firstOfBitSizeHelper {
	using Type = typename conditional<  (sizeof(First) == bitCount / 8),
		First,
		typename firstOfBitSizeHelper<bitCount, Types...>::Type
	>::type;
};

template<unsigned bitCount, typename... Types>
using firstOfBitsize = typename firstOfBitSizeHelper<bitCount, Types..., void>::Type;

using u8 = firstOfBitsize<8, unsigned char>;
using u16 = firstOfBitsize<16, unsigned short, unsigned int>;
using u32 = firstOfBitsize<32, unsigned short, unsigned int, unsigned long>;
using u64 = firstOfBitsize<64, unsigned int, unsigned long, unsigned long long>;

using s8 = firstOfBitsize<8, signed char>;
using s16 = firstOfBitsize<16, signed short, signed int>;
using s32 = firstOfBitsize<32, signed short, signed int, signed long>;
using s64 = firstOfBitsize<64, signed int, signed long, signed long long>;

using f32 = firstOfBitsize<32, float, double>;
using f64 = firstOfBitsize<64, float, double, long double>;

using USize = u64;
using SSize = s64;

#endif
