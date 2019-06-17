From: Oleg Drokin <green@whamcloud.com>
Date: Mon, 17 Jun 2019 16:30:24 +0000
Subject: [lustre-devel] Additional testing on reviews
Message-ID: <9B27101C-F0E6-4E4D-AE7E-DDCD049D28F2@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   As we all know it?s the tests and configurations that are not executed that break the most.
   In order to prevent everything to be tailored to a ingle maloo ?monoculture? in our testing,
   I?ve been running a separate test rig(s) for integration testing with full-debug kernel and
   such that was helping to find issues not found in maloo for one reason or another.
   The setup is also tailored to mimic how a developer would setup their Lustre testing with
   out of tree test execution (as opposed to the lengthly rpm building process).
   This was a pretty useful exercise, but somewhat expensive in terms of found bugs (in the
   sense that bugs should preferably be found earlier, not later in the development cycle,
   since the later it?s found the more steps need to be redone including various reviews and
   such).
   Now similarly with what I?ve done with static code analysis, I am doing for at least some
   bits of testing too: You will see comments from ?Lustre Gerrit Janitor? on your (master-only
   for now) patches denoting build and testing progress.
   Importantly - this is not a replacement of maloo/autotest testing, this is just additional
   testing aimed at providing more coverage where it was currently lacking:

   - All builds are only for centos 7 (I plan to switch to rhel8.0 as soon as it?s stable
     enough in my setup) and only x86_64 (I might add ARM but it?s not a priority ATM).
   - Everything runs out of a build tree. You?ll get an early warning if your new test is
     not working in that configuration and I expect you to fix it or talk to me about possible
     needed changes to make it work on the infrastructure side.
     People love to hate on this configuration, but I strongly believe this is a useful setup
     so I will insist on this working going forward so people keep running tests at least
     somewhat during their development (which everybody already does anyway, right?)
   - test cluster configuration is a somewhat limited: one client node and one server node where
     on the server node we have MGS (combined into MDT1), one or two MDTs (2.5G) and two OSTs(4G)
     on tcp-only networking.
     * But at least I have a whole bunch of them so hopefully things would move fast.
   - Only a single test script is run per session
   - No hard failover testing (tests that do it unconditionally are frowned upon, ahem, recovery small-test 136)
   - It runs every sensible working test
     * notable exception is sanity-gss that crashes a lot and I was told is unsupported.
     * it tries to divine by what you changed for what tests don?t need to be run and what tests
       need to be run as a priority because you changed the test file itself.
     * all tests run in parallel (subject to cluster availability)
   - Tests runs are split into two sections: initial and comprehensive testing:
     * Normally initial is just basic runtests with ldiskfs+DNE, zfs and SSK configurations, but the list
       would also include every testscript you happened to touch and everything you requested
       in the Test-parameters string.
     * If initial testing did not fail for some reason, then the rest of tests would be run in the
       comprehensive group.

   Since I want this to be developer friendly (which also helps me) there?s additional information
   you get out of those test runs:
   - Idea is to get a quick turnaround. build ready in under 10 minutes, initial testing complete
     in under 15 minutes, full test session is done in a little more over 2 hours (not currently
     possible because some tests like conf-sanity take longer. Work is underway to split them into
     several)
   - You always get all syslogs and all console logs no matter if test failed or succeeded
   - For crashed tests you?ll see if this if a known triaged failure because an LU- ticket number
     would be listed, otherwise you?ll see something like "(Untriaged #824, seen 2 times before)?
     This tells you how often did we see this crash from multiple sources including autotest.
     You can see all the other hits if you paste the untriaged number into this url:
     https://knox.linuxhacker.ru/crashdb_ui_external.py.cgi?newid= after the ?=? sign.
     while it looks like a full featured triaging ui, it would not let you triage anything so
     if you want to make some known - email me for now.
     * Additionally for crashed tests if you go into the test results link for it, you will see there:
       vmcore and debug vmlinux + lustre modules - in case you want to dig in yourself.
       lustre debug log extracted from the vmcore.
       backtrace processed by the crash tool with source line numbers attached
       (additionally if the backtrace comes from anywhere in your patch and the crash is new enough,
       it will post an early comment at that location in gerrit to save you a click).
   - For timeouts - a crashdump is taken from both server and client nodes and same information is
     extracted as above in case you wanted to check for something yourself (hopefully helps
     with debugging those pesky timeouts)
   - For a regular test failure you?ll get a status if the failure was seen on the baseline branch
     recently or if it?s believed to be a new one. It?s not 100% perfect, but it?s good enough, so
     obviously do pay attention to the ?new? failures (conf-sanity 69 has a variable error message,
     consider not doing that in the future)
   - Additionally logs are checked for other conditions and warning (shown as new or old depending
     on if it was seen before on a baseline branch or not) would be printed.
     Currently checked for (new warnings should be always looked into ASAP obviously):
     * memory leaks (currently in conf-sanity zfs test 59, LU-12038 ; rarely in sanity zfs)
     * sleeping in atomic context (currently - in runtests in ssk mode LU-12338, sanityn thanks to CRR code and sanity-quota LU-12193)
     * busy inodes
     * linked list manipulation warnings from kernel
     * kobject warning messages
     * busy inodes after umount
     * If you have other ideas for message clearly showing up in kernel logs I can check for - let me know and I?ll add.
     * libc use after free messages in userspace from Lustre tools

    Currently all of this is not fed into maloo DB, but I am thinking if I perhaps should do it, so
    meanwhile there?s no search and you just get a link to your testrun pretty much.
    You can also see current testing queue, some stats and last 100 completed test runs at
    http://testing.linuxhacker.ru:3333/lustre-reports/status.html (useful to find last
    baseline run in particular if you wanted to compare to)

    For those curious how results currently looks like, here?s a sample you can
    take a look at: http://testing.linuxhacker.ru:3333/lustre-reports/366/results.html

    While I tested this a bit at smaller scale, I am sure a bunch of stuff will break as it?s unveiled at the
    full scale, so do let me know if you see anything strange and otherwise bear with me.

    Also feel free to ignore the test results, like I said, these are not binding and would not set +1 or -1
    all by itself, I am just trying to propagate errors to you as early as possible so you can act faster based
    on this information.

    If you have any other cool ideas about how this whole thing could be improved - do let me know as well.

Bye,
    Oleg
