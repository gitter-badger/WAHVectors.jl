module WAHTest

using Base.Test

using WAHVectors

@testset "Internals" begin
    @testset "WAH Vector Elements" begin
        @testset "Constructors" begin
            for i in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                @test WAHVectors.WAHElement(0x00000000, n) == reinterpret(WAHVectors.WAHElement, 0x80000000 + n)
                @test WAHVectors.WAHElement(0x00000001, n) == reinterpret(WAHVectors.WAHElement, 0xC0000000 + n)
            end
        end
        @testset "Operators" begin
            @test (WAHVectors.WAH_LITERAL_ONES & 0x00000000) == WAHVectors.WAH_LITERAL_ZEROS
            @test (WAHVectors.WAHElement(0x00000001, UInt32(6)) & 0xFFFFFFFF) == WAHVectors.WAHElement(0x00000001, UInt32(6))

            for i in 1:100
                n1 = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                n2 = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                n3 = rand(n1:WAHVectors.WAH_MAX_NWORDS)
                v = rand(0x00000000:0x00000001)

                @test (n1 + WAHVectors.WAHElement(v, n2)) == WAHVectors.WAHElement(v, n1 + n2)
                @test (WAHVectors.WAHElement(v, n1) + n2) == WAHVectors.WAHElement(v, n1 + n2)
                @test (WAHVectors.WAHElement(v, n3) - n1) == WAHVectors.WAHElement(v, n3 - n1)
            end
        end
        @testset "iscompressed" begin
            @test !WAHVectors.isruns(WAHVectors.WAH_LITERAL_ZEROS)
            @test !WAHVectors.isruns(WAHVectors.WAH_LITERAL_ONES)
            @test WAHVectors.isruns(WAHVectors.WAH_FULL_ZEROS)
            @test WAHVectors.isruns(WAHVectors.WAH_FULL_ONES)

            @test !WAHVectors.is_zeros_runs(WAHVectors.WAH_LITERAL_ZEROS)
            @test !WAHVectors.is_zeros_runs(WAHVectors.WAH_LITERAL_ONES)
            @test WAHVectors.is_zeros_runs(WAHVectors.WAH_FULL_ZEROS)
            @test !WAHVectors.is_zeros_runs(WAHVectors.WAH_FULL_ONES)

            @test !WAHVectors.is_ones_runs(WAHVectors.WAH_LITERAL_ZEROS)
            @test !WAHVectors.is_ones_runs(WAHVectors.WAH_LITERAL_ONES)
            @test !WAHVectors.is_ones_runs(WAHVectors.WAH_FULL_ZEROS)
            @test WAHVectors.is_ones_runs(WAHVectors.WAH_FULL_ONES)

            for i in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)
                el = WAHVectors.WAHElement(rand(0x00000000:0x7FFFFFFF))

                @test WAHVectors.isruns(e0)
                @test WAHVectors.isruns(e1)
                @test !WAHVectors.isruns(el)
                @test WAHVectors.is_zeros_runs(e0)
                @test !WAHVectors.is_zeros_runs(e1)
                @test !WAHVectors.is_zeros_runs(el)
                @test !WAHVectors.is_ones_runs(e0)
                @test WAHVectors.is_ones_runs(e1)
                @test !WAHVectors.is_ones_runs(el)
            end
        end
        @testset "isliteral" begin
            @test WAHVectors.isliteral(WAHVectors.WAH_LITERAL_ZEROS)
            @test WAHVectors.isliteral(WAHVectors.WAH_LITERAL_ONES)
            @test !WAHVectors.isliteral(WAHVectors.WAH_FULL_ZEROS)
            @test !WAHVectors.isliteral(WAHVectors.WAH_FULL_ONES)

            for i in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)
                el = WAHVectors.WAHElement(rand(0x00000000:0x7FFFFFFF))

                @test !WAHVectors.isliteral(e0)
                @test !WAHVectors.isliteral(e1)
                @test WAHVectors.isliteral(el)
            end
        end
        @testset "nwords" begin
            @test WAHVectors.nwords(WAHVectors.WAH_LITERAL_ZEROS) == 1
            @test WAHVectors.nwords(WAHVectors.WAH_LITERAL_ONES) == 1
            @test WAHVectors.nwords(WAHVectors.WAH_FULL_ZEROS) == WAHVectors.WAH_MAX_NWORDS
            @test WAHVectors.nwords(WAHVectors.WAH_FULL_ONES) == WAHVectors.WAH_MAX_NWORDS

            for i in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)
                el = WAHVectors.WAHElement(rand(0x00000000:0x7FFFFFFF))

                @test WAHVectors.nwords(e0) == n
                @test WAHVectors.nwords(e1) == n
                @test WAHVectors.nwords(el) == 0x00000001
            end
        end
        @testset "runval" begin
            @test WAHVectors.runval(WAHVectors.WAH_FULL_ZEROS) == 0x00000000
            @test WAHVectors.runval(WAHVectors.WAH_FULL_ONES) == 0x00000001

            for i in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)

                @test WAHVectors.runval(e0) == 0x00000000
                @test WAHVectors.runval(e1) == 0x00000001
            end
        end
        @testset "nruns" begin
            @test WAHVectors.nruns(WAHVectors.WAH_FULL_ZEROS) == WAHVectors.WAH_MAX_NWORDS
            @test WAHVectors.nruns(WAHVectors.WAH_FULL_ONES) == WAHVectors.WAH_MAX_NWORDS

            for i in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)

                @test WAHVectors.nruns(e0) == n
                @test WAHVectors.nruns(e1) == n
            end
        end
        @testset "nfree" begin
            @test WAHVectors.nfree(WAHVectors.WAH_FULL_ZEROS) == 0
            @test WAHVectors.nfree(WAHVectors.WAH_FULL_ONES) == 0

            for i in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)

                @test WAHVectors.nfree(e0) == (WAHVectors.WAH_MAX_NWORDS - n)
                @test WAHVectors.nfree(e1) == (WAHVectors.WAH_MAX_NWORDS - n)
            end
        end
        @testset "isfull" begin
            @test WAHVectors.isfull(WAHVectors.WAH_FULL_ZEROS)
            @test WAHVectors.isfull(WAHVectors.WAH_FULL_ONES)

            for i in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                e0 = WAHVectors.WAHElement(0x00000000, n)
                e1 = WAHVectors.WAHElement(0x00000001, n)

                @test WAHVectors.isfull(e0) == (WAHVectors.WAH_MAX_NWORDS == n)
                @test WAHVectors.isfull(e1) == (WAHVectors.WAH_MAX_NWORDS == n)
            end
        end
        @testset "hasroom" begin
            for i in 1:100
                n = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                s = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                e = WAHVectors.WAHElement(0x00000000, n)
                @test WAHVectors.hasroom(e) == (n < WAHVectors.WAH_MAX_NWORDS)
                @test WAHVectors.hasroom(e, s) == (s <= WAHVectors.nfree(e))
            end
        end
        @testset "matchingfills" begin
            for i in 1:100
                n1 = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                n2 = rand(0x00000001:WAHVectors.WAH_MAX_NWORDS)
                v1 = rand(0x00000000:0x00000001)
                v2 = rand(0x00000000:0x00000001)

                @test WAHVectors.matchingfills(WAHVectors.WAHElement(v1, n1), WAHVectors.WAHElement(v2, n2)) == (v1 == v2)
            end
        end
    end
end

end
