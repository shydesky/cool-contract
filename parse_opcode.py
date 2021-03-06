from collections import namedtuple
OPCODE = namedtuple("OPCODE", ["id","innum","out","code"])
op_dict = {
    "00": OPCODE("00", 0, 0, "STOP"), 
    "01": OPCODE("01", 0, 0, "ADD"), 
    "02": OPCODE("02", 0, 0, "MUL"), 
    "03": OPCODE("03", 0, 0, "SUB"), 
    "04": OPCODE("04", 0, 0, "DIV"), 
    "05": OPCODE("05", 0, 0, "SDIV"), 
    "06": OPCODE("06", 0, 0, "MOD"), 
    "07": OPCODE("07", 0, 0, "SMOD"), 
    "08": OPCODE("08", 0, 0, "ADDMOD"), 
    "09": OPCODE("09", 0, 0, "MULMOD"), 
    "0a": OPCODE("0a", 0, 0, "EXP"), 
    "0b": OPCODE("0b", 0, 0, "SIGNEXTEND"), 
    "10": OPCODE("10", 0, 0, "LT"), 
    "11": OPCODE("11", 0, 0, "GT"), 
    "12": OPCODE("12", 0, 0, "SLT"), 
    "13": OPCODE("13", 0, 0, "SGT"), 
    "14": OPCODE("14", 0, 0, "EQ"), 
    "15": OPCODE("15", 0, 0, "ISZERO"), 
    "16": OPCODE("16", 0, 0, "AND"), 
    "17": OPCODE("17", 0, 0, "OR"), 
    "18": OPCODE("18", 0, 0, "XOR"), 
    "19": OPCODE("19", 0, 0, "NOT"), 
    "1a": OPCODE("1a", 0, 0, "BYTE"), 
    "1b": OPCODE("1b", 0, 0, "SHL"), 
    "1c": OPCODE("1c", 0, 0, "SHR"), 
    "1d": OPCODE("1d", 0, 0, "SAR"), 
    "20": OPCODE("20", 0, 0, "SHA3"), 
    "30": OPCODE("30", 0, 0, "ADDRESS"), 
    "31": OPCODE("31", 0, 0, "BALANCE"), 
    "32": OPCODE("32", 0, 0, "ORIGIN"), 
    "33": OPCODE("33", 0, 0, "CALLER"), 
    "34": OPCODE("34", 0, 0, "CALLVALUE"), 
    "35": OPCODE("35", 0, 0, "CALLDATALOAD"), 
    "36": OPCODE("36", 0, 0, "CALLDATASIZE"), 
    "37": OPCODE("37", 0, 0, "CALLDATACOPY"), 
    "38": OPCODE("38", 0, 0, "CODESIZE"), 
    "39": OPCODE("39", 0, 0, "CODECOPY"), 
    "3d": OPCODE("3d", 0, 0, "RETURNDATASIZE"), 
    "3e": OPCODE("3e", 0, 0, "RETURNDATACOPY"), 
    "3a": OPCODE("3a", 0, 0, "GASPRICE"), 
    "3b": OPCODE("3b", 0, 0, "EXTCODESIZE"), 
    "3c": OPCODE("3c", 0, 0, "EXTCODECOPY"), 
    "3f": OPCODE("3f", 0, 0, "EXTCODEHASH"), 
    "40": OPCODE("40", 0, 0, "BLOCKHASH"), 
    "41": OPCODE("41", 0, 0, "COINBASE"), 
    "42": OPCODE("42", 0, 0, "TIMESTAMP"), 
    "43": OPCODE("43", 0, 0, "NUMBER"), 
    "44": OPCODE("44", 0, 0, "DIFFICULTY"), 
    "45": OPCODE("45", 0, 0, "GASLIMIT"), 
    "50": OPCODE("50", 0, 0, "POP"), 
    "51": OPCODE("51", 0, 0, "MLOAD"), 
    "52": OPCODE("52", 0, 0, "MSTORE"), 
    "53": OPCODE("53", 0, 0, "MSTORE8"), 
    "54": OPCODE("54", 0, 0, "SLOAD"), 
    "55": OPCODE("55", 0, 0, "SSTORE"), 
    "56": OPCODE("56", 0, 0, "JUMP"), 
    "57": OPCODE("57", 0, 0, "JUMPI"), 
    "58": OPCODE("58", 0, 0, "PC"), 
    "59": OPCODE("59", 0, 0, "MSIZE"), 
    "5a": OPCODE("5a", 0, 0, "GAS"), 
    "5b": OPCODE("5b", 0, 0, "JUMPDEST"), 
    "60": OPCODE("60", 1, 0, "PUSH1"), 
    "61": OPCODE("61", 2, 0, "PUSH2"), 
    "62": OPCODE("62", 3, 0, "PUSH3"), 
    "63": OPCODE("63", 4, 0, "PUSH4"), 
    "64": OPCODE("64", 5, 0, "PUSH5"), 
    "65": OPCODE("65", 6, 0, "PUSH6"), 
    "66": OPCODE("66", 7, 0, "PUSH7"), 
    "67": OPCODE("67", 8, 0, "PUSH8"), 
    "68": OPCODE("68", 9, 0, "PUSH9"), 
    "69": OPCODE("69", 10, 0, "PUSH10"), 
    "6a": OPCODE("6a", 11, 0, "PUSH11"), 
    "6b": OPCODE("6b", 12, 0, "PUSH12"), 
    "6c": OPCODE("6c", 13, 0, "PUSH13"), 
    "6d": OPCODE("6d", 14, 0, "PUSH14"), 
    "6e": OPCODE("6e", 15, 0, "PUSH15"), 
    "6f": OPCODE("6f", 16, 0, "PUSH16"), 
    "70": OPCODE("70", 17, 0, "PUSH17"), 
    "71": OPCODE("71", 18, 0, "PUSH18"), 
    "72": OPCODE("72", 19, 0, "PUSH19"), 
    "73": OPCODE("73", 20, 0, "PUSH20"), 
    "74": OPCODE("74", 21, 0, "PUSH21"), 
    "75": OPCODE("75", 22, 0, "PUSH22"),
    "76": OPCODE("76", 23, 0, "PUSH23"),
    "77": OPCODE("77", 24, 0, "PUSH24"),
    "78": OPCODE("78", 25, 0, "PUSH25"),
    "79": OPCODE("79", 26, 0, "PUSH26"),
    "7a": OPCODE("7a", 27, 0, "PUSH27"),
    "7b": OPCODE("7b", 28, 0, "PUSH28"),
    "7c": OPCODE("7c", 29, 0, "PUSH29"),
    "7d": OPCODE("7d", 30, 0, "PUSH30"),
    "7e": OPCODE("7e", 31, 0, "PUSH31"),
    "7f": OPCODE("7f", 32, 0, "PUSH32"),
    "80": OPCODE("80", 0, 0, "DUP1"),
    "81": OPCODE("81", 0, 0, "DUP2"),
    "82": OPCODE("82", 0, 0, "DUP3"),
    "83": OPCODE("83", 0, 0, "DUP4"),
    "84": OPCODE("84", 0, 0, "DUP5"),
    "85": OPCODE("85", 0, 0, "DUP6"),
    "86": OPCODE("86", 0, 0, "DUP7"),
    "87": OPCODE("87", 0, 0, "DUP8"),
    "88": OPCODE("88", 0, 0, "DUP9"),
    "89": OPCODE("89", 0, 0, "DUP10"),
    "8a": OPCODE("8a", 0, 0, "DUP11"),
    "8b": OPCODE("8b", 0, 0, "DUP12"),
    "8c": OPCODE("8c", 0, 0, "DUP13"),
    "8d": OPCODE("8d", 0, 0, "DUP14"),
    "8e": OPCODE("8e", 0, 0, "DUP15"),
    "8f": OPCODE("8f", 0, 0, "DUP16"),
    "90": OPCODE("90", 0, 0, "SWAP1"),
    "91": OPCODE("91", 0, 0, "SWAP2"),
    "92": OPCODE("92", 0, 0, "SWAP3"),
    "93": OPCODE("93", 0, 0, "SWAP4"),
    "94": OPCODE("94", 0, 0, "SWAP5"),
    "95": OPCODE("95", 0, 0, "SWAP6"),
    "96": OPCODE("96", 0, 0, "SWAP7"),
    "97": OPCODE("97", 0, 0, "SWAP8"),
    "98": OPCODE("98", 0, 0, "SWAP9"),
    "99": OPCODE("99", 0, 0, "SWAP10"),
    "9a": OPCODE("9a", 0, 0, "SWAP11"),
    "9b": OPCODE("9b", 0, 0, "SWAP12"),
    "9c": OPCODE("9c", 0, 0, "SWAP13"),
    "9d": OPCODE("9d", 0, 0, "SWAP14"),
    "9e": OPCODE("9e", 0, 0, "SWAP15"),
    "9f": OPCODE("9f", 0, 0, "SWAP16"),
    "a0": OPCODE("a0", 0, 0, "LOG0"), 
    "a1": OPCODE("a1", 0, 0, "LOG1"), 
    "a2": OPCODE("a2", 0, 0, "LOG2"), 
    "a3": OPCODE("a3", 0, 0, "LOG3"), 
    "a4": OPCODE("a4", 0, 0, "LOG4"), 
    "d0": OPCODE("d0", 0, 0, "CALLTOKEN"), 
    "d1": OPCODE("d1", 0, 0, "TOKENBALANCE"), 
    "d2": OPCODE("d2", 0, 0, "CALLTOKENVALUE"), 
    "d3": OPCODE("d3", 0, 0, "CALLTOKENID"), 
    "d4": OPCODE("d4", 0, 0, "ISCONTRACT"), 
    "f0": OPCODE("f0", 0, 0, "CREATE"), 
    "f1": OPCODE("f1", 0, 0, "CALL"), 
    "f2": OPCODE("f2", 0, 0, "CALLCODE"), 
    "f3": OPCODE("f3", 0, 0, "RETURN"), 
    "f4": OPCODE("f4", 0, 0, "DELEGATECALL"), 
    "f5": OPCODE("f5", 0, 0, "CREATE2"), 
    "fa": OPCODE("fa", 0, 0, "STATICCALL"), 
    "fd": OPCODE("fd", 0, 0, "REVERT"), 
    "ff": OPCODE("ff", 0, 0, "SUICIDE")
}

def parse(data):
    ret = []
    try:
        index = 0
        op = ""
        while index < len(data):
            op = data[index: index+2]
            tmp = op_dict.get(op)
            if tmp is None:
                print(index)
            pc = hex(int(index / 2))[2:].rjust(4,"0")
            index = index + 2
            param = ""
            if tmp.code.find("PUSH") >= 0:
                pc_skip = int(tmp.code[4:]) * 2
                param = data[index: index + pc_skip]
                index = index + pc_skip
            ret.append(pc + "|  " + "{:>15s}".format(tmp.code) + "    " + "{:<10s}".format(param))
            
    except Exception as e:
        print(e)
    return ret
    