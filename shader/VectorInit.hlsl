#include "/Test/STF/ShaderTestFramework.hlsli"

template<typename... ArgTypes>
struct all_same_type : ttl::false_type {};

template<typename FirstType>
struct all_same_type<FirstType> : ttl::true_type {};

template<typename FirstType, typename SecondType, typename... OtherTypes>
struct all_same_type<FirstType, SecondType, OtherTypes...> : ttl::false_type {};

template<typename FirstType, typename... OtherTypes>
struct all_same_type<FirstType, FirstType, OtherTypes...> : all_same_type<FirstType, OtherTypes...> {};

template<typename... ArgTypes>
static const bool all_same_type_v = all_same_type<ArgTypes...>::value;

static_assert(!all_same_type_v<>, "Expected all_same_type_v<> to be false");
static_assert(all_same_type_v<int>, "Expected all_same_type_v<int> to be true");
static_assert(all_same_type_v<int, int>, "Expected all_same_type_v<int, int> to be true");
static_assert(all_same_type_v<int, int, int>, "Expected all_same_type_v<int, int, int> to be true");
static_assert(!all_same_type_v<int, float, int>, "Expected all_same_type_v<int, float, int> to be false");
static_assert(!all_same_type_v<int, int, int, int, float>, "Expected all_same_type_v<int, int, int, int, float> to be false");

[numthreads(1, 1, 1)]
void VectorInit()
{
    const uint3 value = uint3(1u, uint2(2u, 3u));
    ASSERT(AreEqual, value.x, 1u);
    ASSERT(AreEqual, value.y, 2u);
    ASSERT(AreEqual, value.z, 3u);
}
