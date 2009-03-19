From: Vitaly Fertman <Vitaly.Fertman@Sun.COM>
Date: Thu, 19 Mar 2009 22:34:55 +0300
Subject: [Lustre-devel] LustreFS performance (update)
In-Reply-To: <02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>
References: <3376C558-E29A-4BB5-8C4C-3E8F4537A195@sun.com>
	<02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>
Message-ID: <FBA6537A-EC86-450A-B44F-3CDBDAF8AADD@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

****************************************************
	LustreFS benchmarking methodology.
****************************************************

The document aims to describe the benchmarking methodology which helps
to understand the LustreFS performance and reveal LustreFS bottlenecks  
in
different configurations on different hardware, to ensure the next  
LustreFS
release does not downgrade comparing with a previous one. In other  
words:
	Goal1. Understand the HEAD performance.
	Goal2. Compare HEAD and b1_6 (b1_8) performance.

To achieve the Goal1, the methodology suggests to test different  
layers of
software in the bottom-top direction, i.e. the underlying back-end,  
the target
server sitting on this back-end, the network connected to this target  
and how
the target performs through this network, etc up to the whole cluster.
Each next step has only 1 change over the previous one, it is either a  
new layer
added or 1 parameter in the configuration is changed (probably another  
network
type or another back-end). Comparing the results of each test with the  
previous
test, we get the overhead of the added layer or the performance impact  
of
changing this parameter.

To achieve the Goal2, the methodology suggests to go in the reverse  
top-bottom
direction, i.e. to test some large sub-systems first and, if a  
downgrade vs. a previous
LustreFS version is detected, to perform more detailed tests. (This is  
considered as
the primary goal of the 2.0 Performance Team).

The document does not cover the way of fixing revealed problems,  
probably some
special purpose test needs to be run or oprofile needs to be compiled  
in -- it is our
of scope of the document.

Obviously, it is not possible to perform all the thousands of tests in  
all the configurations,
running all the special purpose tests, etc, the document tries to  
prepare:
1) all the essential and sufficient tests to see how the system  
performs in general;
2) some minimal amount of essential tests to see how the system scales  
in different
conditions.
Therefore, the plan does not guarantee we will not miss a bottleneck  
or a bug, it just
tries to cover maximum possible scenarios in most interesting  
conditions/environment
states.

The amount of tests described below is already about 2K, and there  
will be definitely more,
and it will take a lot of time to perform all of them and to analyze  
the results.  So one of
the major concerns here is how to minimize the amount of test so that  
we would not miss
some interesting case and would be able to get all the results within  
a reasonable amount of
time. Please keep it in mind while looking at the tests below.

**** Hardware Requirements. ****

The test plan implies that we change only 1 parameter (cpu or disk or  
network)
on each step. The HW requirements are:

-- at least 1 node with:
  CPU:32;
  RAM: enough to have a ramdisk for MDS;
  DISK: enough disks for raid6 or raid1+0 (as this node could be mds  
or ost);
	  an extra disk for external journal;
  NET: both GiGe and IB installed.
-- at least 1 another node includes:
  DISK: enough disks for raid6 or raid1+0 (as this node could be mds  
or ost);
	  an extra disk for external journal;
-- besides that: 8 clients, 3 other servers.
-- the other servers include:
  DISK: raid6
  NET: IB installed.
-- client includes:
NET: both GiGe and IB installed.

**** Software requirements ****

1. Short term.
1.1 mdsrate
to be completed to test all the operations listed in MDST3 (see below).
1.2 mdsrate-**.sh
to be fixed/written to run mdsrate properly and test all the  
operations listed in
MDST3 (see below).
1.3. fake disk
implement FAIL flag and report 'done' without doing anything in  
obdfilter to get
a low-latency disk.
1.4. MT.
add more tests here and implement them.

2. Long term.
2.1. mdtstack-survey
- an echo client-server is to be written for mds similar to ost.
- a test script similar to obdfilter-survey.sh is to be written.

**** Different configurations ****

Configuration of Node:
RAM. Amount of RAM on nodes (?)
CPU. Count of CPUs on nodes (1..32)
DISK. Disk type (raid, ramdisk, fake)
JOUR. Journal type (internal, external, ram)

Q:  which raid?
A: use RAID 1+0 for MDS; RAID6 for OST.

fake: to get a low-latency disk, it is preferable to report 'done'  
without doing anything
in obdfilter once some FAIL flag is set. It is useful for OST testing,  
because first of all,
it does not have a CPU overhead of memcpy of using ramdisk and it lets  
to test large
amount of data in contrast to ramdisk. As a drawback, it skips the  
localfs code paths.

Note: OSS back-end has write through cache; MDS back-end has write- 
back cache.

Configuration of Cluster:
CL. Amount of clients (1,2,4,8)
MDS. Amount of MDS nodes (1,2,4).
OSS. Amount of OSS nodes (1,2,4)
NET. Network type (GiGe, IB)
OSTN. Amount of OST per nodes (1,2,4)

Configuration of test.
TH. Amount of threads per client (1,2,4,8)
VER. Lustre version (b1_6, HEAD. later b1_8).
FEAT. Lustre features to turn off (COS, SA, RA, debug messages)
TEST. Specific test parameters.

**** Testing ****
Low Layers Testing (LLT)
LLT1. Raw disk (lustre-iokit:sgpdd-survey)
LLT2. Local filesystem (lustre-iokit: ior-survey, is fs mounted  
synchronously?)

Network Testing (NETT).
NETT1. lnet: lnetself test.
NETT2. OBD: lustre-iokit: (obdfilter-survey, 	echo_client-osc-..- 
net-..-ost-echo_server)
NETT3. MD: (not ready)

OST Testing (OSTT).
OSTT1. Isolated OST (lustre-iokit: obdfilter-survey, 	echo_client- 
obdfilter-..-disk)
OSTT2. Remote OST (lustre-iokit: obdfilter-survey,	echo_client-osc-..- 
ost-obdfilter-..-disk)
OSTT3. Client-OST IO (lustre-iokit: ior-survey, client-ost-disk).

MDS Testing (MDST).
MDST1. Isolated MDS test (not ready)
MDST2. Remote MDS test (not ready)
MDST3. Simple Client-MDS operation test

Mixed testing (MT) (not ready)

**** Statistics ****

During all the tests the following is supposed to be running on all  
the servers:
1) HP collectl or LLNL's LMT;
2) smth else?

*** Goal1. Understand the HEAD performance. ***

The Goal1 describes the testing methodology in the bottom-top direction,
from the lower layers (disk) to the complete Lustre cluster.

LLT1. Raw disk (lustre-iokit:sgpdd-survey)
RAM: fixed
CPU: 1
DISK: raid,ramdisk,fake (default=raid)
JOUR:-
CL: 1
OSS:1
NET: -
OSTN:-
TH: 1,2,4,8 (default=1)
F: debug
TEST:
*)bulk size is specified as rszlo/rszhi=[1,4,64,1024K]
*)TH is specified as thrlo/thrhi=[1,2,4,8]
*)the amount of objects to work on in parallel: crglo=crghi=[1;TH]
i.e. test only cases when all the threads work on the same file and
when all of them work on a separate file.
TEST=[bulk;separate or commin file]=8 tests;

Test matrix(TESTxTHxDISK):
Run TESTs with different amount of threads for each DISK.
TESTxTHxDISK=(8x4 - 1)x3=93 tests.
"-1" because TH=1 is already covered.

Total:93 tests.

*** NETT1. lnetself test.***

RAM: fixed
CPU: 1,8,32 (default=1)
DISK: -
JOUR:-
CL: 1,8 (default=1)
OSS:1
NET: GiGe, IB (default=IB)
OSTN:1
TH: 1,2,4,8 (default=1)
F: debug
TEST:
*) test type: PING,READ,WRITE tests
*) bulk size for READ/WRITE: 1k,4k,64k,1M
[1 ping + 4 reads + 4 writes] = 9 tests

Test matrix (TESTxCLxTHxNETxCPU):
1. Multi-thread test.
Run TESTs on CL=1 with different amount of threads.
TESTxTH=[1+4+4]x4=36 tests.
2. Multi-client test
Note: to be more demonstrative, the maximum amount of threads could be  
taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients.
TESTxCLxTH=9x1x4=36 tests.
3. Network test
As the nature of IB is different from GiGe, we need to repeat all the  
tests from (1,2) here.
36+36=72 tests.
4. CPU test
Note: lnet fixes from Liang to be applied here.
Run TESTs on different amount of CPU.
It is mostly interesting to look at large amount of threads, as we are
going to benefit from handling them in parallel.
At the same time, if some HW (network) limit is reached, the result  
will not be
very demonstrative, so test with 1 small & 1 large bulk size only:[1k; 
1024K]:
[CL=8,TH=1,2,4,8]. TESTxCLxTHxCPU=5x1x4x(3-1)=40.

Total: 184 tests.

*** NETT2. OBD performance ***
lustre-iokit: obdfilter-survey, case=network.
	
The results of this tests are to be compared with lnet results to get
the osc+ost+ptlrpc overhead.

RAM: fixed
CPU: 1
DISK: -
JOUR:-
CL: 1,8 (default=1)
OSS:1
NET: IB
OSTN:1
TH: 1,2,4,8 (default=1)
F: debug
TEST:
*) bulk size: rszlo=rszhi=N (1,4,64,1024)
*) TH is specified through: thrlo=1, thrhi=8 (thread count, 1,2,4,8)
*) the amount of objects is: nobjlo=nobjhi=[1;TH]
i.e. test only cases when all the threads work on the same file and
when all of them work on a separate file.
TEST=[4 bulks; common or separate file]=8 tests

Test matrix(TESTxTHxCL):
1. Multi-thread test.
Run TESTs on CL=1 with different amount of threads. TESTxTH=8x4=32 tests
2. Multi-client test
Note: to be more demonstrative, the maximum amount of threads should  
be taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients.
TESTxCLxTH=8x1x4=32 tests.
3. Network test.
Having IB results in hand after (1,2) and these results from NETT1, we  
already see how
osc+ost+ptlrpc changes the behavior. There is no reason to repeat them  
for GiGe, it seems.
4.CPU test
Note: lnet fixes from Liang to be applied here.
Run TESTs on different amount of CPU.
It is mostly interesting to look@large amount of threads, as we are
going to benefit from handling them in parallel.
At the same time, if some HW (network) limit is reached, the result  
will not be
very demonstrative, so test with 1 small & 1 large bulk size only:[1k; 
1024K]:
[CL=8,TH=1,2,4,8]. TESTxCLxTHxCPU=4x1x4x(4-1)=48.

Total: 112 tests.

*** OSTT1. Isolated OST ***
lustre-iokit: obdfilter-survey, case=disk

The results of this tests are to be compared with LLT results to get  
the OST
stack overhead.

RAM: fixed
CPU: 1,8,32 (default=1)
DISK: raid, fake (default=fake)
JOUR: int, ext, ram, (default=ext)
CL: 1
OSS:1
NET: -
OSTN:1,2,4 (default=1)
TH: 1,2,4,8 (default=1)
F: debug
TEST:
*) bulk size: rszlo=rszhi=N (1,4,64,1024K)
*) TH is specified through: thrlo=1, thrhi=8 (1,2,4,8)
*) each OST is supposed to be configured on a separate disk.
*) the amount of objects is: nobjlo=nobjhi=[1;TH]
i.e. test only cases when all the threads work on the same file and
when all of them work on a separate file.
TEST=[4 bulks; common of separate file]=8 tests

Test matrix(TESTxTHxOSTNxDISKxJOURxCPU):
1. Multi-thread test.
Run TESTs on OSTN=1 with different amount of threads. TESTxTH=8x4=32  
tests
2. Multi-OST test
2.1. Let's check how OSTs vs. threads per OST scale (TH=OSTN).
2.2. Let's check how the system scale with many OSTs and threads  
(TH=8*OSTN).
[OSTN>1;TH=OSTN,8*OSTN]. TESTxOSTNxTH=8x2x2=32 tests.
3. DISK test
As other disks are completely different, so lets repeat most of the  
(1,2) for 2 others:
[TH=OSTN;8*OSTN]: TESTxOSTNxTHxDISK=8x3x2x1=48
4. JOURNAL test.
Limit the tests with only raid-disk.
Limit the test with only 1 large and 1 small bulk:[1,1024K].
TESTxOSTNxTHxJOUR: 4x3x2x2=48
5. CPU test
Note: lnet fixes from Liang to be applied here.
Run TESTs on different amount of CPU. It is better to perform it on a  
fast
backend (DISK=fake) to see how CPU really matters.
It is mostly interesting to look at large amount of threads, as we are  
going
to benefit from handling them in parallel.
Also, run with a small & a large bulk only:[1,1024K]
[OSTN=4,TH=1,2,4,8]: TESTxOSTNxTHxCPU=4x1x4x2=32

Total: 192 tests.

*** OSTT2. Real OST test ***
lustre-iokit: obdfilter-survey, case=netdisk

This test is a composition of OBD performance and Isolated OST tests,
so its results are to be compared with NETT2 & OSTT1 results.

RAM: fixed
CPU: 1,8,32 (default=1)
DISK: fake
JOUR: ext
CL: 1,8 (default=1)
OSS:1,2,4 (default=1)
NET: IB
OSTN:1,2,4 (default=1)
TH: 1,2,4,8 (default=1)
F: debug
TEST:
*) bulk size: rszlo=rszhi=N (1,4,64,1024)
*) TH is specified through: thrlo=1, thrhi=8 (thread count, 1,2,4,8)
*) each OST is supposed to be configured on a separate disk.
*) the amount of objects is: nobjlo=nobjhi=[1;TH]
i.e. test only cases when all the threads work on the same file and
when all of them work on a separate file.
TEST=[4 bulks; common of separate file]=8 tests

Test matrix(TESTxTHxCLxCPUxOSSxOSTN):
1. Multi-thread test.
Run TESTs on CL=1 with different amount of threads. TESTxTH=8x4=32 tests
2. Multi-client test
Note: to be more demonstrative, the maximum amount of threads could be  
taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients.
TESTxCLxTH=8x1x4=32 tests.
3. Network test
Having IB results in hand after (1,2) and these results from NETT2, we  
already see how
osc+ost+ptlrpc+obdfilter changes the behavior. Thus, there is no  
reason to repeat them
for GiGe, it seems.
4.CPU test
Note: lnet fixes from Liang to be applied here.
Run TESTs on different amount of CPU.
It is mostly interesting to look at large amount of threads, as we are
going to benefit from handling them in parallel.
At the same time, if some HW (network) limit is reached, the result  
will not be
very demonstrative, so test with 1 small & 1 large bulk size only:[1k; 
1024K]:
[CL=8,TH=1,2,4,8]. TESTxCLxTHxCPU=4x1x4x(3-1)=32.
5. OSTN test.
The same OSC, network, CPU, disk, just check how OST stack (see 1,2  
tests) is scalable.
5.1. Let's check how N threads per 1 OST vs. 1 thread per N OST scales  
(CL=OSTN).
5.2. Let's check how the system scale with many clients and threads  
(CL=8)
Note: to be more demonstrative, the maximum amount of threads could be  
taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients.
As the different with (1,2) on the OSS part only, it is enough to test  
in separate directories
only.  It seems enough to look at 1 small & 1 large bulk only: [1,1024K]
[CL=OSTN,8;TH=1,8]. TEST=2. TESTxCLxTHxOSTN=2x2x2x2=16 tests
6. OSS test.
6.1. Let's check how 1 thread per N OST vs. 1 thread per N OSS scales  
(CL=OSS).
6.2. Let's check how the system scale with many clients and threads  
(CL=8)
Note: to be more demonstrative, the maximum amount of threads could be  
taken
<8, if TH=8 reaches the maximum network throughput with small amount  
of clients.
As the different with (1,2) on the OSS part only, it is enough to test  
in separate directories
only. It seems enough to look at 1 small & 1 large bulk only: [1,1024K]
[CL=OSS,8;TH=1,8]. TEST=2. TESTxCLxTHxOSTN=2x2x2x2=16 tests

Total:128 tests

*** OSTT3. Client-OST test ***
lustre-iokit: ior-survey.

The test results are to be compared with OSTT2 results to get the  
overhead
for Lustre Client: client stack, distributed locking, etc.

RAM: fixed
CPU: 1,8,32 (default=1)
DISK: fake
JOUR: ext
CL: 1,8 (default=1)
OSS:1,2,4 (default=1)
NET: IB
OSTN:1,2,4 (default=1)
TH: 1,2,4,8 (default=1)
F: debug
TEST:
*) CL is specified through $clients_hi
*) TH is specified through $tasks_per_client_hi
*) bulk is specified through  rsize_lo/hi (1,4,64,1028K)
*) file_per_task=[0;1]
i.e. test only cases when all the threads work on the same file and
when all of them work on a separate file.
TEST=[4 bulks; common of separate file]=8 tests

Test matrix(TESTxTHxCLxCPUxOSSxOSTN): absolutely the same as for OSTT2.

NETT3. MD: (not ready)
MDST1. Isolated MDS (not ready)
MDST2. Remote MDS (not ready)
This set of tests need to be implemented in a utility similar to  
obdfilter-survey
but for MDS testing.

MDST3. Simple Client-MDS operation tests

1. create,mknod,mkdir (symlink, link??)
RAM: fixed
CPU(MDS): 1,8,32 (default=1)
DISK(MDS): ramdisk, raid (default=ramdisk)
DISK(OST): raid
JOUR(MDS): int,ext,ram (default=ext)
CL: 1,8 (default=1)
MDS:1,2,4 (default=1)
OSS:1,2,4 (default=1)
NET: IB
OSTN:1
TH: 1,2,4,8 (default=1)
F: debug
TEST: it will be probably mdsrate/mdsrate-create-small.sh, but it  
needs to be
fixed to support all of these operations, not only create. If so:
*) TH could be specified through THREADS_PER_CLIENT=[1,2,4,8]
*) CL is specified through CLIENTS  or NODES_TO_USE.
*) NOSINGLE should be provided
*) add --dirnum option to COMMAND
*) DIRNUM=[1,TH*CL], so we test a case when all the threads work in the
same dir and when each works in a separate one.
*) nfiles is files-per-dir * DIRNUM
[common or separate dir]=2tests;

Note: we should probably limit the amount of files in 1 directory with  
2M,
otherwise the performance will definitely downgrade.

Test matrix(TESTxTHxCLxCPUxMDSxOSSxDISKxJOUR):
1. Multi-thread test. (mknod)
Run TESTs on CL=1 with different amount of threads. TESTxTH=2x4-1=7  
tests
(not 8 as if TH=1, DIRNUM=1, and this is already covered).
2. Multi-client test (mknod)
Note: to be more demonstrative, the maximum amount of threads could be  
taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients.
TESTxCLxTH=2x1x4=8 tests.
3. OSS (create)
3.1. Let's check how multi-client system scales (TH=OSS).
3.2. Let's check how large load system scales (TH=8)
As the different with (1,2) on the OSS part only, it is enough to test  
in separate directories
only. Stripeness is [1, -1]. TEST=2. TESTxCLxTHxOSS=[2x2x2]x2 +  
[2x2x2]x1(1OSS case)=24
4. Network test
Having IB results in hand after (1,2,3) and these results from NETT1,  
we already see
how mdc+mdt-stack+ptlrpc changes the behavior. There is no reason to  
repeat them
for GiGe, it seems.
5. DISK test. (mknod)
Unlike the OST testing, we do not have echo-md client (MDTT1), thus we  
have not checked
how different disks impact the performance, so we need to check it here.
As difference disks are of completely different nature we need to  
repeat most of (1,2) here
[TH=1,8]: TESTxCLxTHxDISK=(2x2x2-1)x1=7
6. JOURNAL test. (mknod)
Repeat (5) for different journals, but limit the test with raid-disk  
only.
TESTxCLxTHxDISKxJOUR=(2x2x2-1)x1x2=15
7.CPU test (mknod)
Note: lnet fixes from Liang to be applied here.
Run TESTs on different amount of CPU.
It is mostly interesting to look at large amount of threads, as we are
going to benefit from handling them in parallel, so run it for CL=8 only
TESTxCLxTHxCPU=2x1x4x(3-1)=16
8. CMD test. (mkdir)
8.1. Let's check how N threads per 1 MDS vs. 1 thread per N MDS scales  
(CL=MDS).
8.2. Let's check how the system scale with many clients and threads  
(CL=8)
Note: to be more demonstrative, the maximum amount of threads could be  
taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients
These test happens in a separate directory (for each thread) only,  
enough to test with
nid creation policy only. TEST=1. TESTxCLxTHxMDS=1x2x4x2=16 tests.

Total: 16 tests for mkdir, 53 for mknod, 24 for create.

2. stat

RAM: fixed
CPU(MDS): 1,8,32 (default=1)
DISK(MDS): ramdisk
DISK(OST): raid
JOUR: ext
CL: 1,8 (default=1)
MDS: 1,2,4 (default=1)
OSS:1,2,4 (default=1)
NET: IB
OSTN:1
TH: 1,2,4,8 (default=1)
F: debug
TEST: mdsrate/mdsrate-stat-small.sh
*) add THREADS_PER_CLIENT to the script to specify TH
*) CL is specified through CLIENTS  or NODES_TO_USE.
*) NOSINGLE should be provided
*) add --dirnum option to COMMAND
*) DIRNUM=[1,TH*CL], so we test a case when all the threads work in the
same dir and when each works in a separate one.
*) nfiles is files-per-dir * DIRNUM
*) add READDIR_ORDER to test readdir access order (random order is not  
very
interesting for stat).
	[common or separate dir; readdir order]=2 tests.

Test matrix(TESTxTHxCLxCPUxMDSxOSS):
1. Multi-thread test.
Run TESTs on CL=1 with different amount of threads. TESTxTH=2x4-1=7  
tests
(not 16 as if TH=1, DIRNUM=1, and this is already covered).
2. Multi-client test
Note: to be more demonstrative, the maximum amount of threads could be  
taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients.
TESTxCLxTH=2x1x4=8 tests.
3. OSS.
3.1. Let's check how multi-client system scales (TH=OSS).
3.2. Let's check how large load system scales (TH=8)
As the difference with (1,2) on the OSS part only, it is enough to  
test in separate directories
only. Test must be done for create with different stripeness: [1, -1].  
TEST=2.
TESTxCLxTHxOSS=[2x2x2]x2=16
4.CPU test
Note: lnet fixes from Liang to be applied here.
Run TESTs on different amount of CPU.
It is mostly interesting to look at large amount of threads, as we are
going to benefit from handling them in parallel, so run it for CL=8  
only.
TESTxCLxTHxCPU=2x1x4x(3-1)=16
5. CMD test. (mkdir)
5.1. Let's check how N threads per 1 MDS vs. 1 thread per N MDS scales  
(CL=MDS).
5.2. Let's check how the system scale with many clients and threads  
(CL=8)
Note: to be more demonstrative, the maximum amount of threads could be  
taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients.
1 creation policy (nid) is enough: TESTxCLxTHxMDS=2x2x4x2=32 tests.

Total: 79 tests.

3. unlink (mdsrate-create-small.sh)

RAM: fixed
CPU(MDS): 1,8,32 (default=1)
DISK(MDS): ramdisk, raid (default=ramdisk)
DISK(OST): raid
JOUR(MDS): int,ext,ram (default=ext)
CL: 1,8 (default=1)
MDS:1,2,4 (default=1)
OSS:1,2,4 (default=1)
NET: IB
OSTN:1
TH: 1,2,4,8 (default=1)
F: debug
TEST: it will be probably mdsrate/mdsrate-create-small.sh, but it  
needs to be
fixed to support all of these operations, not only create. If so:
*) TH could be specified through THREADS_PER_CLIENT=[1,2,4,8]
*) CL is specified through CLIENTS  or NODES_TO_USE.
*) NOSINGLE should be provided
*) add --dirnum option to COMMAND
*) DIRNUM=[1,TH*CL], so we test a case when all the threads work in the
same dir and when each works in a separate one.
*) nfiles is files-per-dir * DIRNUM
*) add an ability to remove in readdir order to mdsrate test and its  
script.
	[readdir or _create_ order; common or separate dir]=3 (skip readdir/ 
common dir).

Note: we should probably limit the amount of files in 1 directory with  
2M,
otherwise the performance will definitely downgrade.

Test matrix(TESTxTHxCLxCPUxMDSxOSSxDISKxJOUR):
1. Multi-thread test. (mknod)
Run TESTs on CL=1 with different amount of threads. TESTxTH=3x4-2=10  
tests
2. Multi-client test (mknod)
Note: to be more demonstrative, the maximum amount of threads could be  
taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients.
TESTxCLxTH=3x1x4=12 tests.
3. OSS (create)
3.1. Let's check how multi-client system scales (TH=OSS).
3.2. Let's check how large load system scales (TH=8)
As the difference with (1,2) on the OSS part only, it is enough to  
test in separate directories
only. Stripeness is [1, -1]. TEST=4. TESTxCLxTHxOSS=[4x2x2]x2 +  
[4x2x2]x1(1OSS case)=48
4. Network test
Having IB results in hand after (1,2,3) and these results from NETT1,  
we already see
how mdc+mdt-stack+ptlrpc changes the behavior. There is no reason to  
repeat them
for GiGe, it seems.
5. DISK test. (mknod)
Unlike the OST testing, we do not have echo-md client (MDTT1), thus we  
have not checked
how different disks impact the performance, so we need to check it here.
As different disks are of completely different nature we need to  
repeat most of (1,2) here
[TH=1,8]: TESTxCLxTHxDISK=(3x2x2-2)x1=10
6. JOURNAL test. (mknod)
Repeat (5) for different journals, but limit the test with raid-disk  
only.
TESTxCLxTHxDISKxJOUR=(3x2x2-2)x2=20
7.CPU test (mknod)
Note: lnet fixes from Liang to be applied here.
Run TESTs on different amount of CPU.
It is mostly interesting to look at large amount of threads, as we are
going to benefit from handling them in parallel, so run it for CL=8 only
TESTxCLxTHxCPU=3x1x4x(3-1)=24
8. CMD test. (mkdir)
8.1. Let's check how N threads per 1 MDS vs. 1 thread per N MDS scales  
(CL=MDS).
8.2. Let's check how the system scale with many clients and threads  
(CL=8)
Note: to be more demonstrative, the maximum amount of threads could be  
taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients
These test happens in a separate directory (for each thread) only,  
enough to test with
nid creation policy only. TEST=2. TESTxCLxTHxMDS=2x2x4x2=32 tests.

Total: 32 tests for mkdir, 76 for mknod, 48 for create.

4. find (not ready)

**** MT. Mixed testing. ****

MT1. Create-write test.
RAM: fixed
CPU(MDS): 1,8,32 (default=32)
DISK(MDS): ramdisk, raid (default=ramdisk)
DISK(OST): raid
JOUR: ext
CL: 1,8 (default=1)
MDS: 1,2,4 (default=1)
OSS:1
NET: IB
OSTN:1
TH: 1,2,4,8 (default=1)
F: debug
TEST: must be a new one. Each thread creates files in a loop, writes 1  
bulk to each and closes it.
*) it is enough to test with a small bulk only: [1k]
*) [common or separate dir]=2tests;

Test matrix(TESTxTHxCLxCPUxMDSxDISK):
1. Multi-thread test.
Run TESTs on CL=1 with different amount of threads. TESTxTH=2x4-1=7  
tests
(not 8 as if TH=1, it is always in 1 dir, and this is already covered).
2. Multi-client test
Note: to be more demonstrative, the maximum amount of threads could be  
taken <8,
if TH=8 reaches the maximum network throughput with small amount of  
clients.
TESTxCLxTH=2x1x4=8 tests.
3. DISK test.
Check how different disks impact on the performance.
As different disks are of completely different nature we need to  
repeat most of (1,2) here
[TH=1,8]: TESTxCLxTHxDISK=(2x2x2-1)x1=7
4.CPU test
Note: lnet fixes from Liang to be applied here.
Run TESTs on different amount of CPU.
It is mostly interesting to look at large amount of threads, as we are
going to benefit from handling them in parallel, so run it for CL=max
only: [CL=8,TH=1,2,4,8]. TESTxCLxTHxCPU=2x1x4x(4-1)=24
5. CMD test.
5.1. Let's check how N threads per 1 MDS vs. 1 thread per N MDS scales  
(CL=MDS).
5.2. Let's check how the system scale with many clients and threads  
(CL=8)
Note: to be more demonstrative, the maximum amount of threads could be  
taken
<8, if TH=8 reaches the maximum network throughput with small amount  
of clients
These test happens in a separate directory (for each thread) only,  
creation policy=[nid,name].
TEST=2. TESTxCLxTHxMDS=2x2x4x2=32 tests.

Total: 78 tests.

MT2. Create-Readdir test.
RAM: fixed
CPU(MDS): 1,8,32 (default=32)
DISK(MDS): ramdisk, raid (default=ramdisk)
DISK(OST): raid
JOUR: ext
CL: 1,8 (default=1) (1 extra client does "ls -U")
MDS:1,2,4 (default=1)
OSS:1
NET: IB
OSTN:1
TH: 1,2,4,8 (default=1)
F: debug
TEST: must be a new one. Each thread creates files in a loop and  
immediately closes them.
1 thread on another client does "ls -U". It is done in 1 directory.

The test matrix is exactly the same as for MT1. Total: 78 tests.

MT3. untar a kernel.
MT4. pmake (compile a kernel).
RAM: fixed
CPU(MDS): 1,8,32 (default=32)
DISK(MDS): ramdisk, raid (default=ramdisk)
DISK(OST): raid
JOUR: ext
CL: 1
MDS:1,2,4 (default=1)
OSS:1,2,4 (default=1)
NET: IB
OSTN:1
TH: 1
F: debug
TEST: a new one.

Test matrix(TESTxCPUxMDSxOSSxDISK):
1. DISK test.
Check how different disks impact on the performance. TESTxDISK=1
2.CPU test
Note: lnet fixes from Liang to be applied here.
Run TESTs on different amount of CPU.
It is mostly interesting to look@large amount of threads, as we are  
going to benefit from
handling them in parallel, so run it for CL=max only: TESTxCPU=1x(3-1)=2
3. CMD test.
Creation policy=name. TESTxMDS=1x2=2 tests.
4. OSS
As most of the files are small, stripeness does not play any role (=1)
TESTxOSS=1x(3-1)=2.

Total: 7 tests.

MT5. ??? Some more tests ????

**** Goal2. Compare HEAD and b1_6 (b1_8) performance. ****

This paragraph describes the testing methodology in the reverse order  
of testing,
i.e. in the top-bottom direction, making sure new LustreFS (HEAD)  
version does
not downgrade comparing with the previous ones (b1_6/b1_8).

Therefore, the first testing cycle includes:
1) MT, MDST3, OSTT3, NETT1 from the above tests.
2) no CMD tests

In the case a downgrade is detected, lower layer tests are to be run  
until the downgrade
disappear.

**** Goal3. CMD testing. ****

MT, MDST3 tests, their CMD sections.

**** Goal4. Quick weekly MD performance test. ****

1) It covers tests described in MT,MDST sections.
2) MDST: No CPU,OSS,OSTN tests
3) MT: no MT1,MT2 tests
4) Only 1 node configuration:
	MDS on RAID1+0 with write back cache
	OSS on RAID6 with write through cache
	JOUR: external for both servers;
5) Only 1 network:
	IB;
6) Minimal amount of cluster configurations:
	MDS=1; OST=1; [CL,TH]=[1,1],[1,8],[8,8];

MDST1.1: perform only create (not mkdir,mknod) for [common or separate  
dir]=2.
1. Multi-thread test. TESTxTH=2x2-1=3 tests
2. Multi-client test. TESTxCLxTH=2x1x1=2 tests.
Total: 5 tests.

MDST1.2. stat for [common or separate dir; readdir order]=2 tests.
1. Multi-thread test. TESTxTH=2x2-1=3 tests
2. Multi-client test. TESTxCLxTH=2x1x1=2 tests.
Total: 5 tests.

MDST1.3 unlink for [readdir or _create_ order; common or separate dir]=3
(skip readdir/common dir). All tests are done against create (not  
mkdir,mknod).
1. Multi-thread test. TESTxTH=3x2-2=4 tests
2. Multi-client test (mknod) TESTxCLxTH=3x1x1=3 tests.
Total: 7 tests.

MT3. untar a kernel.
MT4. pmake (compile a kernel).
Total: 1 tests.

Total: 19 tests.

--
Vitaly
