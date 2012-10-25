From: Roman Grigoryev <roman_grigoryev@xyratex.com>
Date: Fri, 26 Oct 2012 02:19:46 +0400
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <1351185793.14408.283.camel@pip>
References: <EA3A770421F31B4BB895DD3AB9224495706F0E@fmsmsx119.amr.corp.intel.com>
	<BF3E1573-A1E3-47DF-B1B1-866EB65A0D49@xyratex.com>
	<1351185793.14408.283.camel@pip>
Message-ID: <5089BB02.6060101@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/25/2012 09:23 PM, Brian Behlendorf wrote:
> On Wed, 2012-10-24 at 15:05 -0700, Nathan Rutman wrote:
>> On Oct 24, 2012, at 1:02 PM, "Gearing, Chris" <chris.gearing@intel.com> wrote:
>>
>>> Nathan,
>>>
>>> I'm not 100% sure what you are proposing here, your LAD presentation suggested a 'tune-up' of the current test framework rather than a complete re-write. Which of the two are we discussing?
>> Both...
>> The requirements on the framework language are more relaxed, but for ease of development and developer sanity, I assume that the framework language should match the test language.  So I'm using the test language as the requirements driver, and to gage community preference for that test language.
> Before embarking on building yet another new and custom framework for
> Lustre we should evaluate some existing frameworks.  For example, the
> Autotest project was specifically designed to test the Linux kernel.
> It's open source, looks active, is flexible, and there is detailed
> documentation on how to write tests.  Plus it was designed specifically
> for testing the kernel so there are likely existing file system tests.
>
>   http://autotest.github.com/
>
>   "Autotest is a framework for fully automated testing. It is
>    designed primarily to test the Linux kernel, though it is useful
>    for many other functions such as qualifying new hardware. It's an
>    open-source project under the GPL and is used and developed by a
>    number of organizations, including Google, IBM, Red Hat, and many
>    others."
Brian,
I agree that autotest is interesting tool and could be used for Lustre
tests,  but
it need pretty big improvement if we want to use it for Lustre.

I have made autotest evaluation for quick executing Lustre on 3 or 4
nodes and stopped
this activity after spending 3 days without  good result.
I tried  to find simple way to execute llmount.sh on mds, oss, clients
and run one sanity test.
I cannot found documentation and ask list (now documentation exists:
https://github.com/autotest/autotest/wiki/Synchronizationclientsinmultihoststest).

Sorry for long quote, it is from  Lucas Meneghel Rodrigues(RedHat) answer:
> So yes, autotest does have a mechanism to execute 'distributed' testing,
> as well as 'kvm autotest' does have tests that do use such a testing
> arrangement. In autotest, one of the mechanisms used to coordinate
> execution of tests among different machines is called barrier.
>
> A barrier is a class that blocks test execution until all 'members' have
> 'checked in' the barrier. So, consider this example from the client
> version of netperf:
>
>             if role == 'server':
>                 self.server_start(cpu_affinity)
>                 try:
>                     # Wait up to ten minutes for the client to reach this
>                     # point.
>                     self.job.barrier(server_tag, 'start_%d' % num_streams,
>                                      600).rendezvous(*all)
>                     # Wait up to test_time + 5 minutes for the test to
>                     # complete
>                     self.job.barrier(server_tag, 'stop_%d' % num_streams,
>                                      test_time+300).rendezvous(*all)
>                 finally:
>                     self.server_stop()
>
>             elif role == 'client':
>                 # Wait up to ten minutes for the server to start
>                 self.job.barrier(client_tag, 'start_%d' % num_streams,
>                                  600).rendezvous(*all)
>                 self.client(server_ip, test, test_time, num_streams,
>                             test_specific_args, cpu_affinity)
>                 # Wait up to 5 minutes for the server to also reach this 
> point
>                 self.job.barrier(client_tag, 'stop_%d' % num_streams,
>                                  300).rendezvous(*all)
>
> You can see above that the client only will start the client code if the
> server is active and did check in the barrier
As you could see, it is pretty limited functionality and current
test-framework.sh which just support
command series like below more answer on our needs.
-----------------------------------------------
do_facet $SINGLEMDS "$LCTL set_param mdd.${!var}.sync_permission=0"
do_facet $SINGLEMDS "$LCTL set_param mdt.${!var}.commit_on_sharing=0"
do_node $CLIENT1 mkdir -p -m 755 $MOUNT/$tdir
replay_barrier $SINGLEMDS
do_node $CLIENT2 chmod 777 $MOUNT2/$tdir
do_node $CLIENT1 openfile -f O_RDWR:O_CREAT $MOUNT/$tdir/$tfile
zconf_umount $CLIENT2 $MOUNT2
facet_failover $SINGLEMDS
-----------------------------------------------

There is also one more way to do it
(https://github.com/autotest/autotest/wiki/Autoserv) but in this case
this code
work out of test.

I don't like way of customizing test execution via control files. I
think it could be pretty unfriendly for Lustre developers.
Also there is not clean where and how implement permission control for
safe test execution on life clusters, random execution,
simple plug own code before/after tests steps.

It should be possible to implement this functionality (as usually in
software development) but could be not so simple.
>> Based on the responses so far, it seems that there is a fairly clear preference for Python as a test language, and so I'll propose that Python should be used shorter-term to start replacing test-framework.
> If we decide the Autotest framework is a good fit then we'll want to
> write the tests in python to be consistent with the framework language.
> However, for a first cut it looks like you could use the existing bash
> tests largely unmodified.
I think, it is to pretty complex schema  for developer to use autotest
for executing
bash lustre tests considering Lustre configuration translation to
control files.
Looks like benefits from this schema could get only people who
automate testing(and who often already could have own tools).

Thanks,
    Roman
