#include "/Test/STF/ShaderTestFramework.hlsli"

namespace init
{
    float4 vec()
    {
        return (float4)0;
    }
}

[numthreads(1, 1, 1)]
void VectorInit()
{
    const uint3 value = uint3(1u, uint2(2u, 3u));
    ASSERT(AreEqual, value.x, 1u);
    ASSERT(AreEqual, value.y, 2u);
    ASSERT(AreEqual, value.z, 3u);
}
