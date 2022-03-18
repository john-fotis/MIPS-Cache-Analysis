<h1 align="center"> MIPS Cache Analysis featuring Quicksort and Binary Search <h1>

  <h2> Description: </h2>

  This is the second assignment for my [Computer Architecture Course](https://www.di.uoa.gr/en/studies/undergraduate/114) during my B.Sc in Informatics and Telecommunications.
  The purpose of this project is to study the performance of the memory and cache structure on a [32-bit MIPS processor](https://en.wikipedia.org/wiki/MIPS_architecture). The program which is used to extract our conclusions is based on [Quicksort](https://en.wikipedia.org/wiki/Quicksort) and [Binary Search](https://en.wikipedia.org/wiki/Binary_search_algorithm) algorithms.

  <h2> Developed with: </h2>

  * [QtMips DI](https://github.com/kchasialis/QtMips-Di)

  <h2> Detailed Description: </h2>

  <p> Develop a MIPS program that takes as input an array of 40.000 8-bit positive integers. The program should firstly sort this array and then search the address of a specific number in the sorted array. The result will be then stored into the memory at a 32-bit address named POS. If the number does not exist POS must be 0. The range of acceptable numbers is obviously [1,127] in order to be positive and fit in 8 bits as a signed number. For this reason, the program must also validate that the input is acceptable and abort when otherwise. </p>

  <p> Next step is to test the above code in a series of CPUs which differ in their memory structure. There are three main categories of CPUs. All of them have the same pipeline implementation which includes: </p>

  - Data hazard detection with forwarding
  - Branch resolution in EX stage
  - 2-bit Branch predictor with 5-bit Branch History Table

  <p> The first CPU category consists of the base chip which only has a RAM memory with access time of 40 cycles (read & write). Its clock frequency of 500MHz and its cost is 20€ </p>

  <p> The second CPU has additionally an L1 Program Cache of 8kB and an L1 Data cache of either 4, 8 or 16 kB. You may choose the exact size of the Data cache, knowing that these choices cost +20€, +25€ and +30€ compared to the base chip respectively. Furthermore, you are to select the number of sets, the block size and the degree of associativity in both L1 caches. There is no limit on the number of sets. Block size can be 4, 8, 16 or 32 words. Finally, you may choose a cache associativity of 1-way, 2-way, 4-way etc., with the note that each time we double this value the CPU clock is decreased by 10MHz. </p>

  <p> The third CPU will contain everything you chose in the previous step (RAM and L1 Program & Data configuration) with the addition of an L2 unified cache for instructions and data. This new cache can be either 16kB, 32kB or 64kB, costing +50€, +75€ and +100€ compared to the <strong>second</strong> chip. The Block size and Degree of associativity will be the same as the ones you selected for the previous CPU, so will be the clock frequency. Let also be noted, that the access time of L2 cache (read & write) is 5 cycles. </p>

  <p> All caches should implement Write Back, Write allocate and <a href="https://en.wikipedia.org/wiki/Cache_replacement_policies">LRU</a> replacement policy. According to this information, find the CPU with the best value to cost ratio for each CPU category and then compare the final 3 chips with each other. </p>

  <h2> Results: </h2>

  The scale of the problem causes our input array to contain too many duplicates, thus dropping the performance of the classic quicksort algorithm significantly. Hence, we looked out for better options, and we found out that the [Dutch National Flag Problem](https://en.wikipedia.org/wiki/Dutch_national_flag_problem) describes our situation well enough. For this reason we decided to implemented a quicksort implementation proposed by [Edsger W. Dijkstra](https://en.wikipedia.org/wiki/Edsger_W._Dijkstra). This implementation uses a new three-way partition procedure which breaks the input array in three sets instead of two. On the left side of the array there are placed elements smaller than the pivot and on the right, bigger ones. In the middle segment though, there are elements  equal to the pivot. This way we avoid sorting the same elements over and over again and reduce the recursive calls drastically. Namely, our first program could solve the problem in 49 Billion instructions in CPU 0. With the new partition method, we managed to reduce this number to 3,4 Billion instructions, achieving an astonishing speedup of 14,4 times or an improvement of 1440%. As for the input validation, we decided to scan the array at the start of the program, thus spending 5 * 40.000 for this purpose. Had the array been smaller, we could have implemented this check in the recursive sorting routine - thus spending only 1 instruction to check the already loaded data - but for this scale it proved out a worse strategy as there are too many recursive calls being made.

  Moving on, we started running several tests to find out the best CPU. Because of the number of possible combinations, we had to make specific assumptions before each step, in order to lead us to the desired setup with the least possible simulation time.

  CPU 0:

  * The first chip has only one configuration - plain RAM.
    * Number of sets = 64, Block size = 32, Set associativity = 1

  | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
  | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
  | 20€  | 500MHz | ~3.4B        | ~179,3B      | 52,37 | 0,35867s | 0,139 |

  CPU 1:

  * The program cache is defined with 8kB size. Since there is no drawback in choosing big block size, we will set it to have 32 words in each block in every configuration. The reason for this is that all the instruction are in consecutive memory addresses. However, due to the number of instructions being so low, any block size on this cache will only make a difference of some hundreds of cycles, a very small number in this scale of problem. For the associativity degree, we went with direct mapping, as there is no reason to harm the clock for this cache. The instructions can easily fit in this cache, which means the will be no reason to replace anything after they all arrive. This also guarantees a hit-rate higher than 99.99% since the only misses will happen at the beginning of the program execution.
  * For the data cache, things are not so simple. We know the different sized L1 cache will probably bring quite different results too. So we start by choosing our block size, again at 32 words for the same reason. This time, we consider that the spatial locality benefit this feature offers will be bigger than the cache pollution we will cause. This happens because quicksort compares and swaps closely located numbers on a heavy rate, so it will definitely help having big block of memory loaded in the cache. We will do one test though, to test if this assumption is correct.
  * Since replacements will be more frequent in small-sized data caches, we will run the first tests with 1-way, 2-way and 4-way associativity for the 4kB, 8kB and 16kB respectively. Generally, the smaller the cache is, the more it will benefit from this, as there is a lot of competition for the same blocks and many times we might need to compare two values that exist in the same block which would cause many unnecessary replacements in a direct-mapped cache.

  * 4kB Data cache tests:

    * Number of sets = 32, Block size = 32, Set associativity = 1

    | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
    | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
    | 40€  | 500MHz | ~3.4B        | ~3,9B        | 1,141 | 0,00782s | 3,198 |

    * Number of sets = 16, Block size = 32, Set associativity = 2
  
    | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
    | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
    | 40€  | 490MHz | ~3.4B        | ~3,7B        | 1,089 | 0,00761s | 3,285 |

    * Number of sets = 8, Block size = 32, Set associativity = 4

    | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
    | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
    | 40€  | 480MHz | ~3.4B        | ~3,7B        | 1,089 | 0,00777s | 3,217 |

    ___We notice that the second configuration has the best results overall. Since the cache pollution with such a big block size affects smaller caches more easily, the most reasonable configuration to compare different block sizes at is the 4kB cache. If the 32 words perform better here, they will also perform even better for bigger caches. So we will compare the best configuration from above with the corresponding setup which has 16-word block size.___

    * Number of sets = 32, Block size = 16, Set associativity = 2

    | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
    | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
    | 40€  | 490MHz | ~3.4B        | ~3,8B        | 1,110 | 0,00776s | 3,222 |

  As we see the 32 words are the optimal for our tests. We head on with 8kB data cache. This time, we know that there is no reason to try more than 2-way associativity since it wont perform so good to bring a better value ratio than the 4kB cache did.

  * 8kB Data cache tests:

    * Number of sets = 64, Block size = 32, Set associativity = 1

    | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
    | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
    | 45€  | 500MHz | ~3.4B        | ~3,77B       | 1,102 | 0,00755s | 2,945 |
  
    * Number of sets = 32, Block size = 32, Set associativity = 2
    
    | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
    | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
    | 45€  | 490MHz | ~3.4B        | ~3,7B        | 1,083 | 0,00757s | 2,937 |

  Indeed, we notice that the direct-mapped 8kB cache has a slightly better value over the 2-way one, so there is no reason to try 4-way. So for the 16kB cache we will only test the direct-mapped setup.

  * 16kB Data cache tests:

    * Number of sets = 64, Block size = 32, Set associativity = 1

    | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
    | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
    | 50€  | 500MHz | ~3.4B        | ~3,71B       | 1,085 | 0,00743s | 2,691 |

  We conclude that as we use a bigger cache, the speedup and CPI improve, but the additional cost of these implementations lead us to choose the 4kB model for CPU 1.

  ___Final CPU 1:___

  * L1 program cache => Number of sets = 64, Block size = 32, Set Associativity = 1
  * L1 data cache => Number of sets = 16, Block size = 32, Set Associativity = 2, Write-back, Write allocate, LRU

  CPU 2:

  * We can safely assume that the 16kB L2 cache will be a better value than the 33kB and the 64kB judging from the CPU 1 results. However, we will demonstrate the results for all three cases:

  * 16kB Unified cache tests:

    * Number of sets = 64, Block size = 32, Set associativity = 2

    | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
    | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
    | 90€  | 490MHz | ~3.4B        | ~3,7B        | 1,081 | 0,00756s | 1,470 |

    * Number of sets = 128, Block size = 32, Set associativity = 2

    | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
    | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
    | 115€ | 490MHz | ~3.4B        | ~3,68B       | 1,076 | 0,00752s | 1,116 |

    * Number of sets = 256, Block size = 32, Set associativity = 2

    | Cost | Clock  | Instructions | Total Cycles | CPI   | Time     | Value |
    | :--: | :----: | :----------: | :----------: | :---: | :------: | :---: |
    | 140€ | 490MHz | ~3.4B        | ~3,67B       | 1,073 | 0,00750s | 0,952 |

  We conclude that the best choice for the L2 unified cache is the 16kB option.

  ___Final CPU 2:___

  * L1 program cache => Number of sets = 64, Block size = 32, Set Associativity = 1
  * L1 data cache => Number of sets = 16, Block size = 32, Set Associativity = 2, Write-back, Write allocate, LRU
  * L2 program & data cache => Number of sets = 64, Block size = 32, Set Associativity = 2, Write-back, Write allocate, LRU

  <h2> Final rankings: </h2>

  Comparing the three CPUs we conclude that the best value overall is CPU 1. Despite the fact that the addition of L2 cache achieved to reduce the total cycles and CPI the most, it even ran slower than the L1-only chip in soe cases. We know that this happened because we had too choose 2-way associativity for the L2 cache. If we could choose direct-mapped configuration we would get faster runs than both other chips due to the improved clock. Yet, the gap between the value ratios between CPU 1 and CPU 2 are too big to assume that this would invert the final ranking. Lastly, CPU 0 ranks 3rd, as both in terms of speed and even value, despite its low cost, because the cycle-penalty of RAM is huge compared to the other chips.

  <h2> Comments: </h2>

  Although CPU 1 ranked 1st, we need to clarify that this is heavily affected by the clock frequency we are operating. In general the slower the clock is, the less it will benefit from the addition of cache whatsoever. In our case, the CPU would throttle too much waiting for the data to arrive from the memory and suffered billions of stalls. In a very simple system though, where the clock would be comparable to the memory access time, the outcome would be a lot better. Evenly, CPU 2 would rank 1st, if we were working in the GHz spectrum of clocks. This means that a fast CPU like the ones in nowadays smartphones, will benefit vastly from the existence of an L2 cache since we need to balance the gap between memory access time and the clock as much as we can. This is all done to prevent the processor from stalling and optimise the CPU-effective time.

  <h2> Notes: </h2>

  You can find our code in [ca-II-handout-2.s](https://github.com/john-fotis/MIPS-Cache-Analysis/blob/main/ca-II-handout-2.s) for the QtMips simulator as well as the [QtSpim](http://spimsimulator.sourceforge.net/) version [here](https://github.com/john-fotis/MIPS-Cache-Analysis/blob/main/spimCode.s). You can see the entire list of test we ran for this study in [Implementation Statistics.xlsx](https://github.com/john-fotis/MIPS-Cache-Analysis/blob/main/Implementation%20Statistics.xlsx).

  <h2> Contributors: </h2>

  [katerinagiann](https://github.com/katerinagiann)

  <h2> License: </h2>

  This project is licensed under the [MIT License](https://github.com/john-fotis/MIPS-Cache-Analysis/blob/main/LICENSE.md)
