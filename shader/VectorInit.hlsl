#include "/Test/STF/ShaderTestFramework.hlsli"
#include "/Test/TTL/models.hlsli"

template<typename... InArgTypes>
struct conjunction : ttl::true_type {};

template<typename Type>
struct conjunction <Type> : Type {};

template<typename Type, typename... InArgTypes>
struct conjunction<Type, InArgTypes...> : ttl::conditional_t<(bool)Type::value, conjunction<InArgTypes...>, Type> {};

template<typename... InArgTypes>
static const bool conjunction_v = conjunction<InArgTypes...>::value;

static_assert(conjunction_v<>, "Expected conjunction_v<> to be true");
static_assert(conjunction_v<ttl::true_type>, "Expected conjunction_v<ttl::true_type> to be true");
static_assert(!conjunction_v<ttl::false_type>, "Expected conjunction_v<ttl::false_type> to be false");
static_assert(!conjunction_v<ttl::true_type, ttl::true_type, ttl::false_type>, "Expected conjunction_v<ttl::true_type, ttl::true_type, ttl::false_type> to be true");
static_assert(!conjunction_v<ttl::false_type, ttl::true_type, ttl::true_type>, "Expected conjunction_v<ttl::false_type, ttl::true_type, ttl::true_type> to be true");
static_assert(!conjunction_v<ttl::false_type, ttl::false_type, ttl::false_type>, "Expected conjunction_v<ttl::false_type, ttl::false_type, ttl::false_type> to be true");

template<typename FirstType, typename... OtherTypes>
static const bool all_same_fundamental_base_type_v = 
    conjunction_v<
        ttl::integral_constant<bool, ttl::fundamental_type_traits<FirstType>::is_fundamental>,
        ttl::integral_constant<bool, 
            ttl::is_same_v<typename ttl::fundamental_type_traits<FirstType>::base_type, typename ttl::fundamental_type_traits<OtherTypes>::base_type>
        >...>;

struct Empty{};
struct HasMember{ int a; };

static_assert(all_same_fundamental_base_type_v<int>, "Expected all_same_fundamental_base_type_v<int> to be true");
static_assert(all_same_fundamental_base_type_v<int, int2, int3>, "Expected all_same_fundamental_base_type_v<int, int2, int3> to be true");
static_assert(!all_same_fundamental_base_type_v<int, float>, "Expected all_same_fundamental_base_type_v<int, float> to be false");
static_assert(!all_same_fundamental_base_type_v<int2, float4>, "Expected all_same_fundamental_base_type_v<int2, float4> to be false");
static_assert(!all_same_fundamental_base_type_v<Empty>, "Expected all_same_fundamental_base_type_v<Empty> to be false");
static_assert(!all_same_fundamental_base_type_v<HasMember>, "Expected all_same_fundamental_base_type_v<HasMember> to be false");
static_assert(!all_same_fundamental_base_type_v<int, HasMember>, "Expected all_same_fundamental_base_type_v<int, HasMember> to be false");

template<typename... InArgTypes>
static const uint total_fundamental_scalars_v = (uint(0) + ... + ttl::fundamental_type_traits<InArgTypes>::dim0);

static_assert(total_fundamental_scalars_v<int3, float2, bool4> == 9, "Expected total_fundamental_scalars_v<int3, float2, bool4> to be 9");
static_assert(total_fundamental_scalars_v<int3, Empty, bool4> == 7, "Expected total_fundamental_scalars_v<int3, Empty, bool4> to be 7");
static_assert(total_fundamental_scalars_v<> == 0, "Expected total_fundamental_scalars_v<> to be 0");
static_assert(total_fundamental_scalars_v<Empty> == 0, "Expected total_fundamental_scalars_v<Empty> to be 0");
static_assert(total_fundamental_scalars_v<int16_t2> == 2, "Expected total_fundamental_scalars_v<int16_t2> to be 2");

template<typename DestType, typename SourceType>
ttl::enable_if_t<
    (ttl::fundamental_type_traits<SourceType>::dim0 >  1)
> CopyToVector(inout DestType InOutVec, SourceType InSource, inout uint InOutStartIndex)
{
    const uint numIndices = ttl::fundamental_type_traits<SourceType>::dim0;
    for (uint i = 0; i < ttl::fundamental_type_traits<SourceType>::dim0; ++i)
    {
        InOutVec[InOutStartIndex + i] = InSource[i];
    }
    InOutStartIndex += numIndices;
}

template<typename DestType, typename SourceType>
ttl::enable_if_t<
    (ttl::fundamental_type_traits<SourceType>::dim0 ==  1)
> CopyToVector(inout DestType InOutVec, SourceType InSource, inout uint InOutStartIndex)
{
    InOutVec[InOutStartIndex] = InSource;
    ++InOutStartIndex;
}

template<typename DestType, typename... SourceTypes>
void Cat(inout DestType InOutVec, uint InStartIndex)
{

}

template<typename DestType, typename SourceType, typename... OtherSourceTypes>
void Cat(inout DestType InOutVec, uint InStartIndex, SourceType InSource, OtherSourceTypes... InOtherSources)
{
    CopyToVector(InOutVec, InSource, InStartIndex);
    Cat(InOutVec, InStartIndex, InOtherSources...);
}

namespace v1
{
    template<typename FirstType, typename... OtherTypes>
    auto vec(FirstType InFirst, OtherTypes... InOthers)
    {
        static_assert(all_same_fundamental_base_type_v<FirstType, OtherTypes...>, "All types must have the same fundamental base type");
        static const uint totalScalars = total_fundamental_scalars_v<FirstType, OtherTypes...>;
        static_assert(totalScalars <= 4, "The total number of scalars must be less than or equal to 4");

        auto ret = (vector<typename ttl::fundamental_type_traits<FirstType>::base_type, totalScalars>)0;
        Cat(ret, 0, InFirst, InOthers...);
        return ret;
    }
}

namespace v2
{
    template<typename FirstType, typename... OtherTypes>
    ttl::enable_if_t<
        all_same_fundamental_base_type_v<FirstType, OtherTypes...>,
        vector<typename ttl::fundamental_type_traits<FirstType>::base_type, total_fundamental_scalars_v<FirstType, OtherTypes...>>
    > vec(FirstType InFirst, OtherTypes... InOthers)
    {
        auto ret = (vector<typename ttl::fundamental_type_traits<FirstType>::base_type, total_fundamental_scalars_v<FirstType, OtherTypes...>>)0;
        Cat(ret, 0, InFirst, InOthers...);
        return ret;
    }
}

namespace v3
{
    template<typename FirstType, typename... OtherTypes>
    ttl::enable_if_t<
        all_same_fundamental_base_type_v<FirstType, OtherTypes...>,
        vector<typename ttl::fundamental_type_traits<FirstType>::base_type, total_fundamental_scalars_v<FirstType, OtherTypes...>>
    > vec(FirstType InFirst, OtherTypes... InOthers)
    {
        auto ret = (vector<typename ttl::fundamental_type_traits<FirstType>::base_type, total_fundamental_scalars_v<FirstType, OtherTypes...>>)0;
        uint startIndex = 0;
        CopyToVector(ret, InFirst, startIndex);
        (CopyToVector(ret, InOthers, startIndex), ...);
        return ret;
    }
}

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

static_assert(ttl::models<CVectorInitableV1, float3, float, float, float>::value);
static_assert(ttl::models<CVectorInitableV2, float3, float, float, float>::value);
static_assert(ttl::models<CVectorInitableV3, float3, float, float, float>::value);

//This is a compiler error
//static_assert(!ttl::models<CVectorInitableV1, float3, float, int, float>::value);

static_assert(!ttl::models<CVectorInitableV2, float3, float, int, float>::value);
static_assert(!ttl::models<CVectorInitableV3, float3, float, int, float>::value);


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
}
