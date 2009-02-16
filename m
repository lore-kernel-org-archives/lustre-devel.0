From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Mon, 16 Feb 2009 06:11:02 -0500
Subject: [Lustre-devel] Some investigations on  MDS creation rate
In-Reply-To: <DC147A4B-16CC-41B7-9C27-2F9BE64805FD@Sun.COM>
References: <DC147A4B-16CC-41B7-9C27-2F9BE64805FD@Sun.COM>
Message-ID: <FE7ACA5E-C11C-41B7-BF1D-05F9A73C72DF@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   Ok, a follow up to my findings. First of all it turned out in this  
specific (and quite useless) case of a lot of mknods we do extra  
unneeded lookup RPC
   where we can do without (also in somewhat more useful mkdir case  
too). I filed a bug 18534 with a prototype fix.
   With that fix on top of all previous changes I now see create rate  
of ~8.8k (with peaks into 9.3k territory) creates/sec.
   I also performed tests on HEAD and it performs significantly worse  
(5.8k at most). Even with all the same fixes ported from b1_6.
   The CPU remains the same and I used lock meter to verify that there  
is no significant lock contention.
   Looking into the oprofile results, it looks like all code just  
became slower (judging by more hits in various areas for the same  
workload).
   Also some parts of the code are now more heavily loaded (ptlrpc 
+ldlm in HEAD draws more cpu time, llite portion of the code is 50%  
more time
   (but still from 2% to 3% total cpu time spent, not all that  
significant)).
   Another problem on HEAD is huge variability between runs. Easily  
could be +/- 50% between runs for HEAD where b1_6 results are pretty  
close together.
   I have no idea why the variability and I do not see anything very  
obvious that would explain sudden overall performance degradation of  
HEAD code either yet.

   I have put my oprofile results to http://linuxhacker.ru/lustre-profile 
  the file suffixes are -calls for callgraphs, -func for cpu usage per  
function and
   no prefix for cpu usage per module. oprofile and oprofiled binaries  
substracted from results.
   There are 3 runs of b1_6 and HEAD, every time a fresh filesystem  
was created (this is the only way to do in on HEAD now, since you  
cannot remove 150k files from
   same dir due to bug 17560).
   all 3 runs of b1_6 gave out ~7.8k/sec (lower speed is due to  
oprofile taking cpu).
   head runs 1 and 3 gave 3.0k/sec, while run 2 produced 5.1k/sec.
   It is interesting that in slower HEAD runs lnet takes 60% more  
wallclock cpu time than in faster run and the faster head run has lnet  
at the same
   wall time as b1_6 runs. I do not know yet if that means that  
sometimes HEAD decided to double amount of traffic for some reason or  
if there
   is another explanation too.

   As a comparison I have run createmany with same parameters on just  
ldiskfs, the measurements are less finegrained there, since we just  
divide number of
   creates performed by the time in seconds and creating 150k files on  
ldiskfs takes only 5-6 seconds, so the rate is 25k-30k creates/sec.

Bye,
     Oleg
