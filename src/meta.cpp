#ifndef GMETA
# define GMETA

template<bool B, class T, class F>
struct conditional { typedef T type; };

template<class T, class F>
struct conditional<false, T, F> { typedef F type; };

template<typename T, typename U>
inline constexpr bool is_same = false;

template<typename T>
inline constexpr bool is_same<T, T> = true;

#endif
