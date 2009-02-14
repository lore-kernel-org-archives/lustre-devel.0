From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Sat, 14 Feb 2009 03:47:10 -0500
Subject: [Lustre-devel] Some investigations on  MDS creation rate
Message-ID: <DC147A4B-16CC-41B7-9C27-2F9BE64805FD@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

    Few days ago a question arose (probably not the first time) how  
quickly we can create files on MDS (ignoring OST objects creation for  
now)
    if we have super-low-latency i/o and super low-latency network.  
Branch is b1_6, though I plan to run HEAD like this too.
    I decided that perhaps fully local mount would be good enough for  
the super-fast latency (Eric has some problems with this arguing that
    lo lnd does local memory copy which should be somewhat expensive).
    For super-low latency I made some loop files on tmpfs (I did not  
want to go through real ramdisk, since I think that cuts through some of
    the block-searching logic).
    Also naturally debug was disabled.

    The test was creation of 150000 files in a single dir on lustre  
(not in root).
    As expected, we are 100% cpu-bound in this scenario.
    My somewhat dated Athlon X2 2.1Ghz achieves around 4.6k creates/ 
sec, the problem is there is pretty big variability (easily 10% both  
ways),
    anyway I collected some oprofile traces and the overall picture is  
pretty similar in there across the runs:
    We spend 45+% time in main code, 20+% in ptlrpc+ldlm, 9% in  
ldiskfs, 5-7% in lnet, ~3% in mds, ~3% in jbd.
    When looking at the functions, the main offender is  
do_gettimeofday with 12+% of total cpu time, but the callgraph implies  
that
    it is not called from Lustre.
    second worst is memset_c with 4+%, what is interesting here is  
that 79% of calls to long memsets are from init_inode, zeroing out  
i_dquot
    field (600+ bytes on x86_64, 440 bytes on i686), another 16% are  
from .test.d_free and I am not sure what that means.
    next is add_dirent_to_buf (in ldiskfs) with 2.5-3.5%
    Somewhat surprisingly, ptlrpc_main is 2.4% of cpu as well.
    There is also plenty of schedule-related activity (schedule,  
try_to_wake_up, and friends) which when combined should give not so  
small % of cpu of 5.4%

    I decided to look at ptlrpc_main to see what's so bad about it and  
sure enough, I see recent code that basically makes it to run at least  
twice for
    every incoming request and in different threads at that. After a  
patch (below), create speed seemed to be better, but still was pretty  
variable.
    oprofile shows that scheduling activity significantly descreased  
(and ptlrpc_main easily takes 30% less time now), but then other code  
starts to
    take more time at random (esp. ldiskfs related and memsets).
    One of my suspicions is perhaps cpu-pingpong of tasks (I thought  
that dualcore cpus do not have all that much penalty for cpu  
switching, but might
    be I was wrong about that), I pinned all mds threads to one cpu  
and tried to run createmany from another, that bumped overall create  
speed to
    around 5k creates/sec and with ptlrpc_main patch to 5130 creates/ 
sec.
    Another thing I noticed is add_waitq_exclusive is adding tasks to  
the tail of waitq with the logic of (shared waiters go to the  
beginning since they
    need to be woken up anyway, and we only need to wake up one  
exclusive task). This really does not bode well with our usage  
scenario, all of our
    service threads are exclusive waiters, and so we are constantly  
rotate through them throwing away ones that are hot in the cache and  
replacing them
    with stale old ones (well, not code, but stack and such). As an  
experiment, I replaced the __add_wait_queue_tail with __add_wait_queue  
in
    add_wait_queue_exclusive() on top of all previous changes and I  
now consistently see 5370 creates/sec.

    I guess I need to run client and server on separate nodes since  
that might cut variability, but then getting superfast network would  
be a lot harder.

    The tests were pretty simplistic in a sense that there was not a  
lot of contention on MDS (due to single-threaded nature of creates),  
but somewhat
    interesting anyway.

    I wonder if anyone might be has ideas about other reasons for big  
variability in individual function times for the same workload.

--- ptlrpc/service.c	11 Feb 2009 08:42:10 -0000	1.114.30.44
+++ ptlrpc/service.c	14 Feb 2009 08:43:24 -0000
@@ -1156,7 +1156,6 @@ ptlrpc_server_handle_req_in(struct ptlrp
          rc = ptlrpc_server_request_add(svc, req);
          if (rc)
                  GOTO(err_req, rc);
-        cfs_waitq_signal(&svc->srv_waitq);
          RETURN(1);

  err_req:
@@ -1654,14 +1653,15 @@ static int ptlrpc_main(void *arg)
                  if (!list_empty(&svc->srv_reply_queue))
                          ptlrpc_server_handle_reply (svc);

+recheck_queue:
                  if (!list_empty(&svc->srv_req_in_queue)) {
                          /* Process all incoming reqs before handling  
any */
                          ptlrpc_server_handle_req_in(svc);
                          /* but limit ourselves in case of flood */
                          if (counter++ < 1000)
-                                continue;
-                        counter = 0;
+                                goto recheck_queue;
                  }
+                counter = 0;

                  if (svc->srv_at_check)
                          ptlrpc_at_check_timed(svc);


Bye,
     Oleg
