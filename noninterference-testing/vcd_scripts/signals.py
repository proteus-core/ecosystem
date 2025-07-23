import re
import sys
from vcdvcd import VCDVCD


def get_liberal_security_signals(example_vcdfile):
    """
    Generate standard security signals for a given core configuration.

    Returns:
    Signal: An object containing the generated security signals.
    """
    all_signals = VCDVCD(example_vcdfile).references_to_ids.keys()

    # Only keep signals related to the pipeline
    all_signals = [s for s in all_signals if "TOP.Core.pipeline" in s]

    signals_patterns = []
    
    # PC and state of the branch predictor
    signals_patterns.append(r'.*BranchTargetPredictor.entries_\d+_pc')
    signals_patterns.append(r'.*BranchTargetPredictor.entries_\d+_target')
    signals_patterns.append(r'.*registerMap_PC')
    signals_patterns.append(r'.*registerMap_PREDICTED_PC')

    # Data bus
    signals_patterns.append(r'.*dbus_cmd_payload_address')
    signals_patterns.append(r'.*dbus_cmd_valid')

    # ICache metadata
    signals_patterns.append(r'.*cache_ibus_cache_\d+_\d+_tag')
    signals_patterns.append(r'.*cache_ibus_cache_\d+_\d+_valid')

    # DCache metadata
    signals_patterns.append(r'.*cache_dbus_cache_\d+_\+d_tag')
    signals_patterns.append(r'.*cache_dbus_cache_\d+_\d+_valid')

    # Control signals
    signals_patterns.append(r'.*ready')
    signals_patterns.append(r'.*arbitration_isDone')
    signals_patterns.append(r'.*isAvailable')
    signals_patterns.append(r'.*[v|V]alid')

    # Pipeline flush
    signals_patterns.append(r'.*JUMP_REQUESTED')
    
    signals = [s for s in all_signals if any(re.match(pattern, s) for pattern in signals_patterns)]

    return signals


def get_conservative_security_signals(example_vcdfile):
    """
    Returns all signals from a VCD file, except signals related to data.
    This is stronger than get_std_security_signals() (more signals are checked).

    Parameters:
    example_vcdfile (str): The path to the VCD file.

    Returns:
    list: A list of filtered signal names.

    TODO: Not super thoroughly tested: likely more signals should be filtered out.
    """

    all_signals = VCDVCD(example_vcdfile).references_to_ids.keys()

    # Only keep signals related to the pipeline
    all_signals = [s for s in all_signals if "TOP.Core.pipeline" in s]

    # Filter out signals related to data
    # #TODO: perhaps too coarse grained (I did not check carefully that all signals are fine to filter out)
    data_patterns = re.compile(r'.*data.*|.*DATA.*|.*Data.*|.*writeValue.*')

    # Filter out cache signals for data
    cache_patterns = [
        r'.*cache_dbus_cache_\d+_\d+_value',
    ]
    combined_cache_pattern = re.compile('|'.join(cache_patterns))

    # Filter out ALU data signals
    alu_patterns = [
        r'.*intAlus_\d+.IntAlu_result',
        r'.*intAlus_\d+.IntAlu_src\d+',
        r'.*intAlus_\d+.out_LSU_TARGET_ADDRESS',
        r'.*intAlus_\d+.BranchUnit_..',
        r'.*intAlus_\d+.value_ALU_RESULT',
        r'.*intAlus_\d+.out_ALU_RESULT',
        r'.*intAlus_\d+.out_IntAlu_src\d+',
        r'.*intAlus_\d+.Shifter_src',
        r'.*intAlus_\d+.BranchUnit_target',
        r'.*intAlus_\d+.BranchUnit_src\d+',
    ]
    combined_alu_pattern = re.compile('|'.join(alu_patterns))

    # Filter out register file signals for data
    regfile_patterns = [
        r'.*RegisterFileAccessor.regs_spinal_port\d+',
        r'.*Core.pipeline.RegisterFileAccessor.regs\(\d+\)',
        r'.*Core.pipeline.RegisterFileAccessor.x\d+_t\d',
        r'.*Core.pipeline.RegisterFileAccessor.x\d+_s\d_fp',
    ]
    combined_regfile_pattern = re.compile('|'.join(regfile_patterns))

    # TODO: Problem with "when" signals
    # When signals usually indicate a change in the pipeline state
    # However, taken in isolation, they are not always meaningful 
    #
    # Example:
    # Signal TOP.Core.pipeline.intAlus_1.when_PcManager_l31
    # This signal guards exception handling for misaligned instruction addresses
    # It only makes sense to look at it when the instruction is a branch as the trap handler is also guarded by BU_IsBranch signal
    # However, the signal is also changed when instruction is not a branch
    # This will trigger false positives
    #
    # Perhaps looking at combinations of signals could solve this issue?
    # Or maybe the conclusion is that these when signals are not adapted for security analysis?
    when_patterns = [
        r'.*intAlus_1.when_PcManager_l\d+', # misaligned instruction address
    ]
    combined_when_pattern = re.compile('|'.join(when_patterns))



    # Data forwarding signals
    data_forwarding_patterns = [
        r'.*Scheduler_rob_previousStoreBuffer', # StoreToLoadForwarding, forwards last store to load (can potentially be secret)
    ]
    combined_data_forwarding_patterns = re.compile('|'.join(data_forwarding_patterns))   

    all_signals = [s for s in all_signals if not (data_patterns.match(s) or
                                                  combined_alu_pattern.match(s) or
                                                  combined_regfile_pattern.match(s) or
                                                  combined_cache_pattern.match(s) or
                                                  combined_when_pattern.match(s) or
                                                  combined_data_forwarding_patterns.match(s))]

    return all_signals


def get_retired_signals(example_vcdfile):
    """
    Returns all signals from a VCD file, that correspond to the retirement stage.
    Can be used to check for correctness by comparing two traces that should be equivalent.
    => Such comparison only works if the programs are very slightly different: same number of
    instructions, same memory layout, etc.
    => For instance, one can compare programs with fences and programs with nops.

    Parameters:
    example_vcdfile (str): The path to the VCD file.

    Returns:
    list: A list of filtered signal names.

    TODO: Not super thoroughly tested
    """
    all_signals = VCDVCD(example_vcdfile).references_to_ids.keys()
    # Only keep signals related to the pipeline retirementStage
    all_signals = [s for s in all_signals if "TOP.Core.pipeline.retirementStage" in s]
    
    return all_signals