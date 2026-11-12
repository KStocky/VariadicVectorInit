#ifndef VECTOR_INIT_HLSLI
#define VECTOR_INIT_HLSLI

#include "/Test/TTL/type_traits.hlsli"

template<typename... InArgTypes>
struct conjunction : ttl::true_type {};

template<typename Type>
struct conjunction<Type> : Type {};

template<typename Type, typename... InArgTypes>
struct conjunction<Type, InArgTypes...> : ttl::conditional_t<(bool)Type::value, conjunction<InArgTypes...>, Type> {};

template<typename... InArgTypes>
static const bool conjunction_v = conjunction<InArgTypes...>::value;

template<typename FirstType, typename... OtherTypes>
static const bool all_same_fundamental_base_type_v =
    conjunction_v<
        ttl::integral_constant<bool, ttl::fundamental_type_traits<FirstType>::is_fundamental>,
        ttl::integral_constant<bool,
            ttl::is_same_v<typename ttl::fundamental_type_traits<FirstType>::base_type, typename ttl::fundamental_type_traits<OtherTypes>::base_type>
        >...>;

template<typename... InArgTypes>
static const uint total_fundamental_scalars_v = (uint(0) + ... + ttl::fundamental_type_traits<InArgTypes>::dim0);

template<typename DestType, typename SourceType>
ttl::enable_if_t<
    (ttl::fundamental_type_traits<SourceType>::dim0 > 1)
> CopyToVector(inout DestType InOutVec, SourceType InSource, inout uint InOutStartIndex)
{
    static const uint numIndices = ttl::fundamental_type_traits<SourceType>::dim0;
    for (uint i = 0; i < numIndices; ++i)
    {
        InOutVec[InOutStartIndex + i] = InSource[i];
    }
    InOutStartIndex += numIndices;
}

template<typename DestType, typename SourceType>
ttl::enable_if_t<
    (ttl::fundamental_type_traits<SourceType>::dim0 == 1)
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

        auto ret = (vector<typename ttl::fundamental_type_traits<FirstType>::base_type, totalScalars>)0;
        Cat(ret, 0, InFirst, InOthers...);
        return ret;
    }
}

namespace v2
{
    template<typename FirstType, typename... OtherTypes>
    ttl::enable_if_t<
        (all_same_fundamental_base_type_v<FirstType, OtherTypes...>),
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

#endif
