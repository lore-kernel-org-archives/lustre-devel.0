From: Keith Mannthey <keith@whamcloud.com>
Date: Wed, 22 Aug 2012 15:08:33 -0700
Subject: [Lustre-devel] [wc-discuss] Test failures with Lustre latest
	release(2.2.93)
In-Reply-To: <F62E2618FCA29E42AB21F281C9511BB413EE4CD9B0@MX26A.corp.emc.com>
References: <F62E2618FCA29E42AB21F281C9511BB413EE4CD9B0@MX26A.corp.emc.com>
Message-ID: <CABy1qO2OrSbKYdbEU2uGDG41qKEpxY=QuwQHgw-QOPKEAcVNOg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Aug 22, 2012 at 2:58 AM, Zhang, Kelly <kelly.zhang@emc.com> wrote:

> Hello,****
>
> ** **
>
> Do you guys meet the following two failures with *Lustre latest
> release(2.2.93)*?  Have they already been logged in Maloo?****
>
> ** **
>
> == sanity test 200: OST pools == 15:56:58 (1345449418)****
>
> Creating new pool****
>
> lustre1oss1: Pool lustre.cea1 created****
>
> Waiting 90 secs for update****
>
> Adding targets to pool****
>
> lustre1oss1: add the named OSTs to the pool****
>
> lustre1oss1: usage pool_add <fsname>.<poolname> <ostname indexed list>****
>
> sanity test_200: @@@@@@ FAIL: lfs pool_list bad ost count 0 != 1****
>
>   Trace dump:****
>
>   = /usr/lib64/lustre/tests/test-framework.sh:3614:error_noexit()****
>
>   = /usr/lib64/lustre/tests/sanity.sh:8564:pool_add_targets()****
>
>   = /usr/lib64/lustre/tests/sanity.sh:8777:test_200()****
>
>   = /usr/lib64/lustre/tests/test-framework.sh:3869:run_one()****
>
>   = /usr/lib64/lustre/tests/test-framework.sh:3898:run_one_logged()****
>
>   = /usr/lib64/lustre/tests/test-framework.sh:3772:run_test()****
>
>   = /usr/lib64/lustre/tests/sanity.sh:8806:main()****
>
> Dumping lctl log to
> /tmp/test_logs/2012-08-20/154136/sanity.test_200.*.1345449428.log****
>
>
>
Yes I know of this first issue, it can be seen at
http://jira.whamcloud.com/browse/LU-1410.
There is a problem running sanity test 200.  We know for sure running with
1 OST only is has this problem and there is a patch to fix the test in the
LU.

It is a simple test change. Please let us know if you use the change and
still have this issue.

== racer test 1: racer on clients: lustre1cl1 DURATION=300 == 16:47:45
> (1345452465)****
>
> lustre1cl1: Reading test skip list from
> /usr/lib64/lustre/tests/cfg/tests-to-skip.sh****
>
> racers pids: 28251 28252****
>
> ** **
>
> Message from syslogd at lustre1cl1 at Aug 20 04:52:46 ...****
>
> kernel:LustreError: 16793:0:(osc_lock.c:205:osc_lock_unuse()) ASSERTION(
> !ols->ols_hold ) failed:****
>
> Message from syslogd at lustre1cl1 at Aug 20 04:52:46 ...****
>
> kernel:LustreError: 16793:0:(osc_lock.c:205:osc_lock_unuse()) LBUG
>


This 2nd issue may be related to
http://jira.whamcloud.com/browse/LU-1772(it is a reported timeout).

Thanks,
 Keith Mannthey
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120822/da74f1a0/attachment.htm>
