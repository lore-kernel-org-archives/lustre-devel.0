From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Sat, 28 Mar 2009 15:08:25 -0400
Subject: [Lustre-devel] Async close RPC
Message-ID: <29A3C6ED-8132-4896-92CB-3518036D84BB@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

    It recently struck me as how unfair many file creation tests are  
to Lustre. The problem is only with tests because they portray Lustre
    creation rates lower than actual speed to be seen by application.  
(same goes for opens, btw).
    The problem is typical create-rate test does an open-close  
sequence in a loop. Now close is synchronous RPC on Lustre in majority  
of tests.
    By making close to be asynchronous we would make Lustre to appear  
more fast at creates by reducing all of that overhead. Of course no
    real application would benefit, because I am not aware of any  
where there is a tight open-close loop there. Real applications are
    opening some files at some point, then do i/o for some extended  
time and only then close would happen.

    I know in some of CMD cases this idea was considered, but did not  
pan out for some reason (I am not familiar with that implementation).

    Anyway I performed a test at ORNL Jaguar system running an  
application creating 10000 files (open-creat, with O_LOV_DELAY_CREATE  
flag to reduce
    OST influence, since we are working separately on addressing that)  
and then closing 10000 files, all in 2 timed loops. The app was run on  
a scale
    of 1 to 64 clients (in power of 2 increments).
    From the test it is easily observable that the closes easily bring  
in 50% penalty to overall creation rate.
    E.g. at a scale 1: 10k opens take 1.946946, 10k subsequent closes  
take 1.031471. (5136 real creates/sec vs 3357 "reported by usual test"  
creates sec)
         at a scale 8: 80k opens take 6.21 sec, 80k subsequent closes  
take 3.51 sec  (12800 real creates/sec vs 8230 "reported by usual  
test" creates sec).

    Now of course if we make closes completely asynchronous, they  
would still be competing for CPU at MDS with opens, inducing some  
penalty still, so
    for this type of test ideally we would like all closes to go to  
some separate portal with only one handling thread to minimize cpu  
consumption, but
    this is not really idea for real workloads, of course, the real  
impact here could be made by NRS, where opens from same job would get  
prioritized
    ahead of closes from the same job.

    Anyway, I am thinking it is good idea to implement async closes if  
only to make us look better (read - more realistic) in these tests,  
and for proper
    implementation to work we need to get rid of close sending  
serialization (since spawning a separate close thread for every close  
would be stupid).
    I think the close serialization is not needed anyway. If the close  
reply was lost, it would be resent and we can just supress the  
resulting error
    seeing how resent close just tried to close nonexistent close  
handle. On recovery we care even less, there is nothing to close after  
server restart.
    (I am not sure what SOM implications that might have? But I  
suspect none - there is some extra state in mfd that could tell us if  
we already executed
    this close and we probably can reconstruct necessary reply state  
for resend from it, Vitaly?)

    Any comments or concerns from anyone?

Bye,
     Oleg
