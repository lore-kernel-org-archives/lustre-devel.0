From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Wed, 13 Feb 2008 10:23:50 -0800
Subject: [Lustre-devel] Global generic database
Message-ID: <47B335B6.5010703@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The design of various new features in Lustre call for global (filesystem 
wide) databases, accessible from
clients or other servers:
A. pools - pool descriptions (pool #1 = OSTs 1-10,30-60), pool policies 
(all .jpg files to pool #1)
B. filesets - fileset policies (log creates on fileset #1 to feed "foo")
C. HSM - (aureleien - what was the use case here?)

We've already implemented at least 2 of these:
D. Fid Location Database - (is this done?)
E. configuration parameters - stored in MGS llogs

Rather than continue 1-off implementations, I think it's time we came up 
with a consistent,
global, generic database mechanism for A-C as well as other future uses.
Needs to be:
1. Fast. We need to cache database entries locally, which also means 
having them under locks.
    a. local caching
    b. locks
2. Generic.  Store any kind of data, not limited to 8k page boundaries, etc.
3. Transactional.  Power loss doesn't lead to inconsistent state.
4. Recoverable. Client changes are replayed if need be.
5. Remotely accessible, from a client or other servers.
