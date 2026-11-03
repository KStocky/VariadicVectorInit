#include "/Test/STF/ShaderTestFramework.hlsli"
#include "/Test/TTL/models.hlsli"

struct CValidVectorInit
{
    template<typename VecType, typename... InArgs>
    __decltype(
        VecType(ttl::declval<InArgs>()...)
    ) requires();
};

static_assert(ttl::models_v<CValidVectorInit, float4, float3, float>, "Expected float4(float3, float) to be valid");
static_assert(!ttl::models_v<CValidVectorInit, float4, float3, float2>, "Expected float4(float3, float2) to be invalid");
static_assert(!ttl::models_v<CValidVectorInit, int3, int, int>, "Expected int3(int, int) to be invalid");

struct A
{
    int a;
};

struct B
{
    float b[2];
};

struct C
{
    bool c;
};

static_assert(ttl::models_v<CValidVectorInit, float4, A, B, C>, "Expected float4(A, B, C) to be valid");

[numthreads(1, 1, 1)]
void CurrentVectorInit()
{
    A a = { 1 };
    B b = { 2.0f, 3.0f };
    C c = { true };

    float4 value = float4(a, b, c);
    ASSERT(AreEqual, value, float4(1.0, 2.0, 3.0, 1.0));
}