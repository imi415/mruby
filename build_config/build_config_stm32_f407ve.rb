MRuby::Build.new do |conf|
  toolchain :gcc

  enable_debug

  # include the default GEMs
  conf.gembox 'default'

end

MRuby::CrossBuild.new("STM32F407VE") do |conf|
  toolchain :gcc

  conf.cc do |cc|
    cc.command = "arm-none-eabi-gcc"
    cc.include_paths << []
    cc.flags = %w( -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -Og -g -Wall )
    cc.compile_options = "%{flags} -o %{outfile} -c %{infile}"

    #configuration for low memory environment
    cc.defines << %w(MRB_HEAP_PAGE_SIZE=64)
    cc.defines << %w(KHASH_DEFAULT_SIZE=8)
    cc.defines << %w(MRB_STR_BUF_MIN_SIZE=20)
    cc.defines << %w(MRB_GC_STRESS)
    
    # Use single precision float instead of double,
    # since Cortex-M4 VFP-v4-SP-D16 only accelerates single precision operations.
    cc.defines << %W(MRB_USE_FLOAT)
  end

  conf.cxx do |cxx|
    cxx.command = conf.cc.command.dup
    cxx.include_paths = conf.cc.include_paths.dup
    cxx.flags = conf.cc.flags.dup
    cxx.flags << %w(-fno-rtti -fno-exceptions)
    cxx.defines = conf.cc.defines.dup
    cxx.compile_options = conf.cc.compile_options.dup
  end

  conf.archiver do |archiver|
    archiver.command = "arm-none-eabi-ar"
    archiver.archive_options = 'rcs %{outfile} %{objs}'
  end

  #no executables
  conf.bins = []

  #do not build executable test
  conf.build_mrbtest_lib_only

  #disable C++ exception
  conf.disable_cxx_exception

  #gems from core
  conf.gem :core => "mruby-print"
  conf.gem :core => "mruby-math"
  conf.gem :core => "mruby-enum-ext"

  #light-weight regular expression
  conf.gem :github => "masamitsu-murase/mruby-hs-regexp", :branch => "master"

end
