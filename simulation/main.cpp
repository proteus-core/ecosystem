#include "VCore.h"

#include <verilated.h>
#include <verilated_fst_c.h>

#include <bit>
#include <atomic>
#include <memory>
#include <vector>
#include <iomanip>
#include <iostream>
#include <fstream>

#include <cstdint>
#include <cassert>
#include <csignal>

#include <sys/select.h>
#include <sys/time.h>

const double TIMESCALE       = 1e-9;
const int    CLOCK_FREQUENCY = 100*1e6;
const int    CLOCK_PERIOD    = 1/(CLOCK_FREQUENCY*TIMESCALE);

const std::uint64_t MAX_CYCLES = 1000000000ULL;

const unsigned int MEMBUS_WORDS = 4;
const unsigned int MEMBUS_OFFSET = 2 + std::bit_width(MEMBUS_WORDS) - 1;

#ifdef USE_MEMORY_TAGS
const unsigned int TAG_GRANULARITY = 8;
const float TAGS_PER_WORD = (float)32 / TAG_GRANULARITY;
const unsigned int TAGBUS_WIDTH = (int)(MEMBUS_WORDS * TAGS_PER_WORD);
const unsigned int TAGBUS_OFFSET = 2 + std::bit_width(TAGBUS_WIDTH) - 1;
#endif

bool logStores = false;
bool csvStores = false;
bool loadTags = false;
std::ofstream storesLog;
std::ofstream storesCsv;

std::atomic<bool> isDone{false};

void handle_sigint(int signal)
{
    if (signal == SIGINT) {
        isDone = true;
    }
}

class Memory
{
public:

    Memory(VCore& top, const char* memoryFile, const std::string &tagsFile) : top_{top}
    {
        auto ifs = std::ifstream{memoryFile, std::ifstream::binary};
        auto memoryBytes =
            std::vector<unsigned char>{std::istreambuf_iterator<char>(ifs), {}};

        assert((memoryBytes.size() > 0) &&
               "Memory file does not exist or is empty");

        assert((memoryBytes.size() % 4 == 0) &&
               "Memory does not contain a multiple of words");

        auto i = std::size_t{0};

        while (i < memoryBytes.size())
        {
            auto b0 = memoryBytes[i++];
            auto b1 = memoryBytes[i++];
            auto b2 = memoryBytes[i++];
            auto b3 = memoryBytes[i++];

            auto word = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
            memory_.push_back(word);
        }

        #ifdef USE_MEMORY_TAGS
        if (loadTags)
        {
            auto ifsTags = std::ifstream{tagsFile, std::ifstream::binary};
            auto tagBytes = std::vector<unsigned char>{std::istreambuf_iterator<char>(ifsTags), {}};
            auto incr = TAG_GRANULARITY / 8;

            for (i = 0; i < tagBytes.size(); i += incr) {
                tags_.push_back(tagBytes[i] != 0 ? true : false);
            }

            for (i = tagBytes.size(); i < memoryBytes.size(); i += incr) {
                tags_.push_back(false);
            }
        } else {
            for (i = 0; i < memoryBytes.size() * TAGS_PER_WORD; i++) {
                tags_.push_back(false);
            }
        }
        #endif
    }

    void eval(vluint64_t cycle)
    {
        top_.io_axi_arw_ready = true;
        top_.io_axi_w_ready = true;
        top_.io_axi_r_valid = false;
        top_.io_axi_b_valid = false;

        if (nextReadCycle_ == cycle)
        {
            for (unsigned i = 0; i < MEMBUS_WORDS; ++i) {
                top_.io_axi_r_payload_data[i] = nextReadData_[i];
            }

            #ifdef USE_MEMORY_TAGS
            top_.io_axi_r_payload_user = 0;
            for (unsigned i = 0; i < TAGBUS_WIDTH; ++i) {
                top_.io_axi_r_payload_user |= (nextReadTags_[i] << i);
            }
            #endif

            top_.io_axi_r_payload_id = nextReadId_;
            top_.io_axi_r_payload_last = true;
            top_.io_axi_r_valid = true;
            nextReadCycle_ = 0;

            assert(top_.io_axi_r_ready);
        }

        if (top_.io_axi_arw_valid)
        {
            if (top_.io_axi_arw_payload_write)
            {
                #ifdef USE_MEMORY_TAGS
                write(top_.io_axi_arw_payload_addr,
                      top_.io_axi_w_payload_strb,
                      top_.io_axi_w_payload_data,
                      top_.io_axi_w_payload_user,
                      cycle);
                #else
                write(top_.io_axi_arw_payload_addr,
                      top_.io_axi_w_payload_strb,
                      top_.io_axi_w_payload_data,
                      0,
                      cycle);
                #endif

                top_.io_axi_b_valid = true;
            }
            else
            {
                #ifdef USE_MEMORY_TAGS
                read(top_.io_axi_arw_payload_addr, nextReadData_, nextReadTags_);
                #else
                read(top_.io_axi_arw_payload_addr, nextReadData_, NULL);
                #endif
                nextReadCycle_ = cycle + 1;
                nextReadId_ = top_.io_axi_arw_payload_id;
            }
        }
    }

    void dump(const std::string &out, const std::string &tagOut, const bool tagDump) {
        std::ofstream memfile(out, std::ios::out | std::ios::binary);
        for (int i = 0; i < memory_.size(); ++i) {
            uint32_t word = memory_[i];
            
            memfile.put(word & 0xFF);
            memfile.put((word >> 8) & 0xFF);
            memfile.put((word >> 16) & 0xFF);
            memfile.put((word >> 24) & 0xFF);
        }
        
        #ifdef USE_MEMORY_TAGS
        if (tagDump) {
            std::ofstream tagfile(tagOut, std::ios::out | std::ios::binary);
            for (int i = 0; i < tags_.size(); ++i) {
                bool tag = tags_[i];
                switch (TAG_GRANULARITY)
                {
                case 8:
                    tagfile.put(tag ? 0x01 : 0x00);
                    break;
                case 16:
                    tagfile.put(tag ? 0x01 : 0x00);
                    tagfile.put(0x00);
                    break;
                case 32:
                    tagfile.put(tag ? 0x01 : 0x00);
                    tagfile.put(0x00);
                    tagfile.put(0x00);
                    tagfile.put(0x00);
                    break;
                case 64:
                    tagfile.put(tag ? 0x01 : 0x00);
                    tagfile.put(0x00);
                    tagfile.put(0x00);
                    tagfile.put(0x00);
                    tagfile.put(0x00);
                    tagfile.put(0x00);
                    tagfile.put(0x00);
                    tagfile.put(0x00);
                    break;
                default:
                    break;
                }
            }
            tagfile.close();
        }
        #endif

        memfile.close();
    }

private:

    using Address = std::uint32_t;
    using Word = std::uint32_t;
    using Mask = std::uint32_t;
    using Tags = std::uint32_t;

    void read(Address address, WDataOutP value, bool *tags)
    {
        ensureEnoughMemory(address);

        auto baseAddress = (address >> MEMBUS_OFFSET) << (MEMBUS_OFFSET - 2);

        for (unsigned i = 0; i < MEMBUS_WORDS; ++i) {
            value[i] = memory_[baseAddress + i];
        }

        #ifdef USE_MEMORY_TAGS
        int tagAddress = (address >> MEMBUS_OFFSET) << (TAGBUS_OFFSET - 2);

        for (unsigned i = 0; i < TAGBUS_WIDTH; ++i) {
            tags[i] = tags_[tagAddress + i];
        }
        #endif
    }

    void write(Address address, Mask mask, WDataInP value, Tags tags, vluint64_t cycle)
    {
        ensureEnoughMemory(address);

        auto bitMask = Word{0};
        auto baseAddress = (address >> MEMBUS_OFFSET) << (MEMBUS_OFFSET - 2);
        std::stringstream csvRow[MEMBUS_WORDS];

        for (unsigned i = 0; i < MEMBUS_WORDS; ++i) {
            bitMask = 0;

            for (int byte = 0; byte < 4; ++byte) {
                if (mask & (1 << (4 * i + byte))) {
                    bitMask |= 0xff << (8 * byte);
                }
            }

            if (bitMask != 0) {
                auto& memoryValue = memory_[baseAddress + i];
                memoryValue &= ~bitMask;
                memoryValue |= value[i] & bitMask;
                if (logStores) {
                    storesLog << std::hex << "Store at " << baseAddress << " with value " << value[i] << std::endl;
                }
                if (csvStores) {
                    csvRow[i] << std::hex << cycle << "," << address << "," << value[i] << ",";
                }
            }
        }

        #ifdef USE_MEMORY_TAGS
        auto storeWidth = __builtin_popcount(mask) * 8;

        auto tagMask = Word{0};
        auto tagAddress = (address >> MEMBUS_OFFSET) << (TAGBUS_OFFSET - 2);
        auto incr = 4 * MEMBUS_WORDS / TAGBUS_WIDTH;

        for (unsigned int i = TAGBUS_WIDTH - 1; i + 1 > 0; --i) {
            tagMask = 0;
            
            for (int byte = 0; byte < incr; ++byte) {
                tagMask |= (mask >> (incr * i + byte) & 0x1) << i;
            }

            if (tagMask != 0) {
                auto tag = (tags >> i & 0x1);
                if (storeWidth >= TAG_GRANULARITY || tag) {
                    tags_[tagAddress + i] = tag ? true : false;
                }
                if (csvStores) {
                    int baseWord = (int)(i / TAGS_PER_WORD);
                    int wordsPerTag = (TAGS_PER_WORD < 1.0f) ? (int)(1.0f / TAGS_PER_WORD) : 1;
                    
                    for (int w = baseWord; w < baseWord + wordsPerTag && w < MEMBUS_WORDS; ++w) {
                        if (csvRow[w].str().length() > 0) {
                            csvRow[w] << tag;
                        }
                    }
                }
            }
        }
        #endif

        for (unsigned int i = 0; i < MEMBUS_WORDS; ++i)
            if (csvRow[i].str().length() > 0)
                storesCsv << csvRow[i].str() << std::endl;
    }

    void ensureEnoughMemory(Address address)
    {
        auto baseAddress = ((address >> MEMBUS_OFFSET) + 1) << (MEMBUS_OFFSET - 2);

        if ((baseAddress) >= memory_.size())
        {
            memory_.reserve(baseAddress + 1);

            while ((baseAddress) >= memory_.size()) {
                memory_.push_back(0xcafebabe);
            }
        }

        #ifdef USE_MEMORY_TAGS
        auto tagAddress = ((address >> MEMBUS_OFFSET) + 1) << (TAGBUS_OFFSET - 2);

        if ((tagAddress) >= tags_.size())
        {
            tags_.reserve(tagAddress + 1);

            while ((tagAddress) >= tags_.size()) {
                tags_.push_back(false);
            }
        }
        #endif
    }

    VCore& top_;
    std::vector<Word> memory_;
    uint32_t nextReadData_[MEMBUS_WORDS];
    vluint64_t nextReadCycle_ = 0;
    vluint8_t nextReadId_;

    #ifdef USE_MEMORY_TAGS
    std::vector<bool> tags_;
    bool nextReadTags_[TAGBUS_WIDTH];
    #endif
};

class CharDev
{
public:

    CharDev(VCore& top) : top_{top}, gotEot_{false}
    {
    }

    void eval()
    {
        if (top_.io_charOut_valid)
        {
            auto charOut = char(top_.io_charOut_payload);

            if (charOut == 0x4)
                gotEot_ = true;
            else
            {
                gotEot_ = false;
                std::cout << charOut;
            }
        }
    }

    bool gotEot() const
    {
        return gotEot_;
    }

private:

    VCore& top_;
    bool gotEot_;
};

class TestDev
{
public:

    TestDev(VCore& top) : top_{top}, result_{-1}
    {
    }

    void eval()
    {
        if (top_.io_testDev_valid)
            result_ = top_.io_testDev_payload;
    }

    bool gotResult() const
    {
        return result_ >= 0;
    }

    bool hasFailed() const
    {
        return gotResult() && result_ != 0;
    }

    int failedTest() const
    {
        assert(hasFailed() && "No failed tests");
        return result_;
    }

private:

    VCore& top_;
    int result_;
};

class ByteDev
{
public:

    ByteDev(VCore& top) : top_{top}
    {
    }

    bool eval()
    {
        if (top_.reset)
            return false;

        top_.io_byteDev_rdata_valid = false;

        if (top_.io_byteDev_wdata_valid)
        {
            auto charOut = char(top_.io_byteDev_wdata_payload);
            std::cout << charOut;
        }

        if (!hasStdinByte && stdinAvailable())
        {
            currentStdinByte = std::cin.get();
            hasStdinByte = !std::cin.eof();
        }

        if (hasStdinByte)
        {
            top_.io_byteDev_rdata_valid = true;
            top_.io_byteDev_rdata_payload = currentStdinByte;

            if (top_.io_byteDev_rdata_ready)
                hasStdinByte = false;

            return true;
        }

        return false;
    }

private:

    bool stdinAvailable() const
    {
        if (std::cin.eof())
            return false;

        fd_set rfds;
        FD_ZERO(&rfds);
        FD_SET(STDIN_FILENO, &rfds);

        timeval tv;
        tv.tv_sec = 0;
        tv.tv_usec = 0;

        int result = select(1, &rfds, nullptr, nullptr, &tv);
        return result == 1;
    }

    VCore& top_;
    char currentStdinByte;
    bool hasStdinByte = false;
};

bool getArg(int argc, char** argv, const std::string& arg, std::string* value = nullptr) {
    for (int i = 1; i < argc; ++i) {
        std::string a = argv[i];

        if (a == "--" + arg && i + 1 < argc) {
            if (value) {
                if (i + 1 < argc) {
                    *value = argv[i + 1];
                    return true;
                }
            } else {
                return true;
            }
        }
    }
    return false;
}

int main(int argc, char** argv)
{
    assert(argc >= 2 && "No memory file name given");

    Verilated::commandArgs(argc, argv);

    std::signal(SIGINT, handle_sigint);

    auto top = std::unique_ptr<VCore>{new VCore};
    top->reset = 1;
    top->clk = 1;

    auto memoryFile = argv[argc - 1];
    
    std::string tagFile;
    loadTags = getArg(argc, argv, "tag-file", &tagFile);

    auto memory = Memory{*top, memoryFile, tagFile};
    auto charDev = CharDev{*top};
    auto testDev = TestDev{*top};
    auto byteDev = ByteDev{*top};

    if (getArg(argc, argv, "help")) {
        std::cout << "--dump-fst <filename>\tDump trace to <filename>\n";
        std::cout << "--dump-mem <filename>\tDump memory to <filename>\n";
        std::cout << "--dump-tags <filename>\tDump tags to <filename>\n";
        std::cout << "--log-stores <filename> \tLog stores to <filename>\n";
        std::cout << "--tag-file <filename> \tRead tag bits from <filename>\n";
        std::cout << "--csv-stores <filename> \tWrite csv rows for stores to <filename>\n";
        std::cout << "--help\tShow command line help\n";
        return 0;
    }

    std::string storesLogFile;
    logStores = getArg(argc, argv, "log-stores", &storesLogFile);
    if (logStores)
        storesLog = std::ofstream(storesLogFile);

    std::string storesCsvFile;
    csvStores = getArg(argc, argv, "csv-stores", &storesCsvFile);
    if (csvStores) {
        storesCsv = std::ofstream(storesCsvFile);
        storesCsv << "cycle,address,value,tag" << std::endl;
    }

    auto tracer = std::unique_ptr<VerilatedFstC>{new VerilatedFstC};
    std::string fstFile;
    bool traceDump = false;
    if ((traceDump = getArg(argc, argv, "dump-fst", &fstFile))) {
        Verilated::traceEverOn(true);
        top->trace(tracer.get(), 99);
        tracer->open(fstFile.c_str());
    }

    std::string memDumpFile;
    bool memDump = getArg(argc, argv, "dump-mem", &memDumpFile);

    std::string tagDumpFile;
    bool tagDump = getArg(argc, argv, "dump-tags", &tagDumpFile);

    vluint64_t mainTime = 0;
    vluint64_t cycle = 0;
    int result = 0;

    while (!isDone)
    {
        auto clockEdge = (mainTime % (CLOCK_PERIOD/2) == 0);

        if (clockEdge)
            top->clk = !top->clk;

        if (mainTime >= 5*CLOCK_PERIOD)
            top->reset = 0;

        top->eval();

        if (clockEdge && top->clk)
        {
            cycle++;

            memory.eval(cycle);
            top->eval();
            //memory.eval(cycle);
            //top->eval();

            charDev.eval();
            testDev.eval();

            if (charDev.gotEot())
                isDone = true;

            if (testDev.gotResult())
            {
                isDone = true;

                if (testDev.hasFailed())
                {
                    std::cerr << "Test " << testDev.failedTest() << " failed\n";
                    result = 1;
                }
                else
                    std::cout << "All tests passed\n";
            }

            if (byteDev.eval())
                top->eval();

            if (mainTime >= MAX_CYCLES*CLOCK_PERIOD)
            {
                isDone = true;
                result = 1;
            }
        }

        if (traceDump) {
            tracer->dump(mainTime);
        }

        mainTime++;
    }

    if (memDump)
        memory.dump(memDumpFile, tagDumpFile, tagDump);

    if (traceDump)
        tracer->close();
    return result;
}
