$cfiles = [System.Collections.ArrayList]::new()
$unrecognized = [System.Collections.ArrayList]::new()


foreach ($arg in $args) {
    if ($arg -clike "*.c") {
        [void]$cfiles.Add($arg.ToString().Replace(".\", ""))
    }
    else {
        [void]$unrecognized.Add($arg)
    }
}

if ($unrecognized.Count -ne 0) {
    Write-Error "Incompatible files passed for compilation: ${unrecognized}"
    Exit 1
}

$binary_name = $cfiles[0].Replace(".c", "-icx.exe")

$cflags = @( 
    "/diagnostics:caret",
    "/DNDEBUG",
    "/D_NDEBUG",
    "/debug:none",
    "/EHa",    # asynchronous C++ exception handling & whithout assuming extern C procedures do not throw.
    "/F0x10485100",
    "/fp:strict",
    "/GF",
    "/guard:cf",
    "/Gw",      # Places each data item in its own COMDAT section.
    "/nologo",
    "/O3",
    "/Oi",
    "/Ot",
    "/Qbranches-within-32B-boundaries",
    "-fcf-protection:full",     #  Enables Intel® Control-Flow Enforcement Technology (Intel® CET) protection
    <#
    "/QaxCORE-AVX512",
    Multiple, feature specific auto-dispatch code paths for Intel® processors.
    The /Qax option tells the compiler to find opportunities to generate separate versions of functions that take
    advantage of features of the specified instruction features.
    If the compiler finds such an opportunity, it first checks whether generating a feature-specific version of a
    function is likely to result in a performance gain. If this is the case, the compiler generates both a feature
    specific version of a function and a baseline version of the function. At runtime, one of the versions is chosen
    to execute, depending on the Intel® processor in use. In this way, the program can benefit from performance
    gains on more advanced Intel processors, while still working properly on older processors and non-Intel
    processors. A non-Intel processor always executes the baseline code path
    
    COULD LEAD TO RUNTIME CRASHES, IS SUCH CRASHES HAPPEN REMOVE THIS COMPILER OPTION.
    WARNING FROM oneAPI DOCUMENTATION.
        
    #>
    "/Qpc80",
    "/Qfp-speculation:strict",
    "/Qipo", # enables -flto=full and -fuse-ld=lld (asks LLVM's linker lld.exe to be used instead of link.exe)
    "/Qimf-precision:high",
    "/Qopt-dynamic-align",  #  compiler may implement conditional optimizations 
    # based on dynamic alignment of the input data. These dynamic alignment optimizations may result in
    # different bitwise results for aligned and unaligned data with the same values.
    "/Qopt-multiple-gather-scatter-by-shuffles",
    # "/Qopt-streaming-stores:always", DANGEROUS
    "/Qsox",
    "/Qvec-peel-loops",
    "/Qvec-remainder-loops",
    "/Qvec-with-mask",
    "/Qunroll:500",
    "/QxCORE-AVX512"
    "/Qm64",
    "/Qvec",
    "/Qvec-threshold:0",    # vectorize always.
    "/std:c2x",
    # "/showIncludes",
    "/tune:core-avx2",
    "/Wall",
    "/Fe:${binary_name}"
)

Write-Host "icx.exe ${cfiles} ${cflags}" -ForegroundColor Cyan
icx.exe $cfiles $cflags    
