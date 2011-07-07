From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 6 Jul 2011 20:25:15 -0600
Subject: [Lustre-devel] Queries regarding Lustre Throughput Numbers with
	mdtest benchmark
In-Reply-To: <BANLkTinfUB6k2ar8g=BrJgcngZSsaYCr_w@mail.gmail.com>
References: <BANLkTinfUB6k2ar8g=BrJgcngZSsaYCr_w@mail.gmail.com>
Message-ID: <B6F73F72-01B8-4925-A50D-D922EF705734@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-06-22, at 5:06 PM, vilobh meshram wrote:
> I have a query regarding Lustre Throughput Numbers with mdtest benchmark.I am running mdtest benhmark with following options :-
> 
> /home/meshram/mpich2-new/mpich2-1.4/mpich2-install/bin/mpirun -np 256 -hostfile ./hostfile ./mdtest -z 3 -b 10 -I 5 -v -d /tmp/l66
> 
> 
> where ,
> mdtest - is the standard benchmark to test metadata operations. [https://computing.llnl.gov/?set=code&page=sio_downloads ]
> /tmp/l66 is my Lustre mount.
> I am using 1Gige Network with TCP transport.
> hostfile has 8 host nodes
> I am varying the number of processes as we can see in following table . 
> I was amazed by the throughput which I got. I think this is too huge. Can someone please let me know if these numbers are correct ?
> 
> 
> 
> 4 Process      : File creation     :      0.501 sec,  44392.140 ops/sec
> 8 Process      : File creation     :      0.685 sec,  64890.598 ops/sec
> 16 Process    : File creation     :      1.426 sec,  62318.798 ops/sec
> 32 Process    : File creation     :      2.947 sec,  60312.766 ops/sec
> 64 Process    : File creation     :      5.630 sec,  63142.760 ops/sec
> 128 Process  : File creation     :     13.208 sec,  53835.707 ops/sec
> 256 Process  : File creation     :     24.601 sec,  57804.777 ops/sec

Seems nobody has responded to your email, and I just found it buried in my
inbox.

I agree that the numbers are quite high, especially for GigE networking.
More typical numbers are in the 5-20k creates/sec (depending on network
and MDS hardware).

That said, the above may not be completely impossible for small file
counts (allowing all of the creates to be served from cache), or if the
client+MDS+OSS are all on the same node (which avoids any network latency).

You also didn't describe the Lustre filesystem, nor what version you are
testing.  This workload has gotten a faster with Lustre 2.1, and it stands
to get faster in Lustre 2.2 also.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
