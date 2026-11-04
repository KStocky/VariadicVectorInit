#include <Framework/AssertionsV1/ShaderTestFixture.h>
#include <catch2/catch_test_macros.hpp>

#include <filesystem>

TEST_CASE("Shader vector initialization", "[shader]")
{
    stf::AssertionsV1::ShaderTestFixture fixture(
        stf::AssertionsV1::ShaderTestFixture::FixtureDesc{
            .Mappings{
                {"/Tests", std::filesystem::current_path() / "Shader"}
            }
        });

    const auto result = fixture.RunTest(
        stf::AssertionsV1::ShaderTestFixture::RuntimeTestDesc{
            .CompilationEnv{
                .Source = std::filesystem::path{"/Tests/VectorInit.hlsl"},
                .CompilationFlags{L"-Wno-hlsl-fold-expressions"}
            },
            .TestName = "VectorInit",
            .ThreadGroupCount{1, 1, 1}
        });

    REQUIRE(result);
}

TEST_CASE("Current vector initialization", "[shader]")
{
    stf::AssertionsV1::ShaderTestFixture fixture(
        stf::AssertionsV1::ShaderTestFixture::FixtureDesc{
            .Mappings{
                { "/Tests", std::filesystem::current_path() / "Shader" }
            }
        });

    const auto result = fixture.RunTest(
        stf::AssertionsV1::ShaderTestFixture::RuntimeTestDesc{
            .CompilationEnv{
                .Source = std::filesystem::path{ "/Tests/CurrentVectorInit.hlsl" }
            },
            .TestName = "CurrentVectorInit",
            .ThreadGroupCount{ 1, 1, 1 }
        });

    REQUIRE(result);
}
