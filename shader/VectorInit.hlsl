#include "/Test/STF/ShaderTestFramework.hlsli"
#include "/Test/TTL/models.hlsli"
#include "/Tests/VectorInit.hlsli"

static_assert(conjunction_v<>, "Expected conjunction_v<> to be true");
static_assert(conjunction_v<ttl::true_type>, "Expected conjunction_v<ttl::true_type> to be true");
static_assert(!conjunction_v<ttl::false_type>, "Expected conjunction_v<ttl::false_type> to be false");
static_assert(!conjunction_v<ttl::true_type, ttl::true_type, ttl::false_type>, "Expected conjunction_v<ttl::true_type, ttl::true_type, ttl::false_type> to be true");
static_assert(!conjunction_v<ttl::false_type, ttl::true_type, ttl::true_type>, "Expected conjunction_v<ttl::false_type, ttl::true_type, ttl::true_type> to be true");
static_assert(!conjunction_v<ttl::false_type, ttl::false_type, ttl::false_type>, "Expected conjunction_v<ttl::false_type, ttl::false_type, ttl::false_type> to be true");

struct Empty{};
struct HasMember{ int a; };

static_assert(all_same_fundamental_base_type_v<int>, "Expected all_same_fundamental_base_type_v<int> to be true");
static_assert(all_same_fundamental_base_type_v<int, int2, int3>, "Expected all_same_fundamental_base_type_v<int, int2, int3> to be true");
static_assert(!all_same_fundamental_base_type_v<int, float>, "Expected all_same_fundamental_base_type_v<int, float> to be false");
static_assert(!all_same_fundamental_base_type_v<int2, float4>, "Expected all_same_fundamental_base_type_v<int2, float4> to be false");
static_assert(!all_same_fundamental_base_type_v<Empty>, "Expected all_same_fundamental_base_type_v<Empty> to be false");
static_assert(!all_same_fundamental_base_type_v<HasMember>, "Expected all_same_fundamental_base_type_v<HasMember> to be false");
static_assert(!all_same_fundamental_base_type_v<int, HasMember>, "Expected all_same_fundamental_base_type_v<int, HasMember> to be false");

static_assert(total_fundamental_scalars_v<int3, float2, bool4> == 9, "Expected total_fundamental_scalars_v<int3, float2, bool4> to be 9");
static_assert(total_fundamental_scalars_v<int3, Empty, bool4> == 7, "Expected total_fundamental_scalars_v<int3, Empty, bool4> to be 7");
static_assert(total_fundamental_scalars_v<> == 0, "Expected total_fundamental_scalars_v<> to be 0");
static_assert(total_fundamental_scalars_v<Empty> == 0, "Expected total_fundamental_scalars_v<Empty> to be 0");
static_assert(total_fundamental_scalars_v<int16_t2> == 2, "Expected total_fundamental_scalars_v<int16_t2> to be 2");

struct CVectorInitableV1
{
    template<typename ExpectedVecType, typename... InArgTypes>
    __decltype(
        ttl::models_if_same<ExpectedVecType, __decltype(v1::vec(ttl::declval<InArgTypes>()...))>()
    ) requires();
};

struct CVectorInitableV2
{
    template<typename ExpectedVecType, typename... InArgTypes>
    __decltype(
        ttl::models_if_same<ExpectedVecType, __decltype(v2::vec(ttl::declval<InArgTypes>()...))>()
    ) requires();
};

struct CVectorInitableV3
{
    template<typename ExpectedVecType, typename... InArgTypes>
    __decltype(
        ttl::models_if_same<ExpectedVecType, __decltype(v3::vec(ttl::declval<InArgTypes>()...))>()
    ) requires();
};

struct CVectorInitableV4
{
    template<typename ExpectedVecType, typename... InArgTypes>
    __decltype(
        ttl::models_if_same<ExpectedVecType, __decltype(v4::vec(ttl::declval<InArgTypes>()...))>()
    ) requires();
};

static_assert(ttl::models<CVectorInitableV1, float3, float, float, float>::value);
static_assert(ttl::models<CVectorInitableV2, float3, float, float, float>::value);
static_assert(ttl::models<CVectorInitableV3, float3, float, float, float>::value);
static_assert(ttl::models<CVectorInitableV4, float3, float, float, float>::value);
//This is a compiler error
//static_assert(!ttl::models<CVectorInitableV1, float3, float, int, float>::value);
static_assert(!ttl::models<CVectorInitableV2, float3, float, int, float>::value);
static_assert(!ttl::models<CVectorInitableV3, float3, float, int, float>::value);
static_assert(!ttl::models<CVectorInitableV4, float3, float, int, float>::value);

//static_assert(!ttl::models<CVectorInitableV1, float3, float, float2, float3>::value);
static_assert(!ttl::models<CVectorInitableV2, float3, float, float2, float3>::value);
static_assert(!ttl::models<CVectorInitableV3, float3, float, float2, float3>::value);
static_assert(!ttl::models<CVectorInitableV4, float3, float, float2, float3>::value);


[numthreads(1, 1, 1)]
void VectorInit()
{
    const uint3 value = uint3(1u, uint2(2u, 3u));
    ASSERT(AreEqual, value.x, 1u);
    ASSERT(AreEqual, value.y, 2u);
    ASSERT(AreEqual, value.z, 3u);

    float3 a = v1::vec(1.0, 2.0, 3.0);
    ASSERT(AreEqual, a, float3(1.0, 2.0, 3.0));

    float3 b = v2::vec(1.0, 2.0, 3.0);
    ASSERT(AreEqual, b, float3(1.0, 2.0, 3.0));

    float3 c = v3::vec(1.0, 2.0, 3.0);
    ASSERT(AreEqual, c, float3(1.0, 2.0, 3.0));

    float3 d = v4::vec(1.0, 2.0, 3.0);
    ASSERT(AreEqual, d, float3(1.0, 2.0, 3.0));

    ASSERT(AreEqual, v1::vec(1.0, 2.0, 3.0), float3(1.0, 2.0, 3.0));
    ASSERT(AreEqual, v1::vec(1, 2, 3), int3(1, 2, 3));
    ASSERT(AreEqual, v1::vec(1, int2(2, 3)), int3(1, int2(2, 3)));

    //float3 d = v2::vec(1.0, 2, false);
}
