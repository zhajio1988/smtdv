// irun UVM_ML argument file - options for running SV
-uvmhome ${UVM_ML_HOME}/ml/frameworks/uvm/sv/1.1d-ml
-sv_lib ${UVM_ML_HOME}/ml/libs/uvm_sv/${UVM_ML_COMPILER_VERSION}/64bit/libuvm_sv_ml.so


// Few verbosity flags (optional - users don't need to use these)
// Note: In ML-OA we set these to ease internal regression - users may prefer *not* to use them
+UVM_NO_RELNOTES                       
-nocopyright                           


