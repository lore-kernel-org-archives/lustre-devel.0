From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 25 Mar 2009 00:37:54 -0400
Subject: [Lustre-devel] ORNL metadata testing results from this Friday.
Message-ID: <E7834A7F-E3A6-4270-8AFA-98A82DF2E00B@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

    Dave Dillow was kind enough to spend some time with me on some  
metadata tests this Friday, two main goals were to find out how much  
the patch from bug 18534
    has on mkdir performance and how big of a drag is there from slow  
OST object creations (the test program was modified to use  
O_LOV_DELAY_CREATE on file open
    to completely skip object creation).
    The test was run with different number of clients, from 1 to 64,  
using mdtest in 2 modes, shared directory and separate directory for  
every client.
    MDS is 16-way SMP node (4x 4-core cpus) with 32G RAM. Infiniband  
interconnect.

    The good news - when we are not disk bound, the patch from 18534  
doubles mkdir rate. Unfortunately at around 8 clients we seem to be  
overflowing journal
    rapidly and that drags performance down very significantly  
(visible in vmstat). Another set of runs was introduced where we used  
ext3 with 1G journal on
    a loop device in a file on tmpfs.

    Strange parts - shared directory file creates (with objects) seems  
to be faster than separate dir-client.

    Another strange thing is that actually not creating any objects  
did not have any dramatic impact on create performance and creates  
still remained 5-10 times slower
    than mkdirs. I tried to reproduce this on my home test machine and  
certainly do not observe anything like this, so this will be next  
thing I will try to figure out at
    ORNL when Dave gets back here. (Before this question arises - yes,  
we did check that files were created without any objects).

    mkdir create rate dives down significantly when we go from 32 to  
64 clients even with journal on ramdisk, which is strange, since there  
should not be
    any significant overhead, I would think we should remain at  
roughly the same level of performance. CPU is at 100%. Unfortunately  
oprofile was not installed.
    (I am not sure that ext3 actually uses more than 400M of journal  
even with external journals, so it could be we overflown entire  
journal and were forced to
    write the changes to actual disk, though now that I think about  
it, I do not remember big spikes in activity on the disk, and we were  
trying to watch it.)

    Attached is an (openoffice) table and my feeble attempts at  
building some graphs in it with test results. There are numbers for  
creates and deletes.
    The test also gathers stat performance, but it behaves very  
similar to unlinks in separate dirs (except much faster, of course),  
so I did not
    entered the numbers into the table.

Bye,
     Oleg
-------------- next part --------------
A non-text attachment was scrubbed...
Name: ORNL MDtest Results.ods
Type: application/vnd.oasis.opendocument.spreadsheet
Size: 61561 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090325/dc66a018/attachment.ods>
-------------- next part --------------
