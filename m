From: Roman Grigoryev <Roman_Grigoryev@xyratex.com>
Date: Mon, 02 Apr 2012 13:43:53 +0400
Subject: [Lustre-devel] [Twg] your opinion about  testing  improvements
In-Reply-To: <F264939C-663E-4A1E-A63A-211026EF6881@whamcloud.com>
References: <4F745E90.2000001@xyratex.com> <4F756360.1000108@xyratex.com>
	<8F4579BA-FE5F-46C3-AC95-998E1195BD89@whamcloud.com>
	<F264939C-663E-4A1E-A63A-211026EF6881@whamcloud.com>
Message-ID: <4F7974D9.3010003@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 04/02/2012 09:33 AM, Andreas Dilger wrote:
> On 2012-04-01, at 9:08 PM, Oleg Drokin wrote:
>> On Mar 30, 2012, at 3:40 AM, Roman Grigoryev wrote:
>>> 2) it is not simple execute(especially in automation) testing for
>>> test. F.e. a bug is fixed, the test on it added. Executing the
>>> test on an old revision(probably on a previous release) should
>>> show failed test result. But with big difference between versions
>>> where fixed and where execute test-framework can fail to start.
>> 
>> I am not quite sure why would you want to constantly fail a test
>> that is known not to work with a particular release due to a
>> missing bugfix. I think it's enough if a developer (or somebody
>> else) runs the test manually once on an unfixed codebase to make
>> sure the test does without the fix.


There can be more then one reason to execute tests which expectedly
failed and  I don't mean an obligation to execute these tests every time
but mean an execution on automated platform in specific cases.

The main problem now is compatibility testing(see below Oleg).
Also there is problematic connection between tests code and lustre code
taking into account consideration that test exclusion is done in test code.

> 
> I think it makes sense to be able to skip a test that is failing for
> versions of Lustre older than X, for cases where the test is
> exercising some fix on the server.  We _do_ run interoperability
> tests and hit these failures, and it is much better to skip the test
> with a clear message instead of marking the test as failed.

Absolutely agree with You about skipping(maybe is good idea to somehow
mark is as not skipped but "incompatible"?).

> 
> Probably the easiest solution is for such tests to explicitly check
> the version of the server, with a new helper function like
> "skip_old_version" or similar.

Maybe we can use just use some kind of keywords to say to framework just
ignore new tests on old setups. I think adding more logic on test level
isn't so good when this new logic process meta information. Test can
just have an attribute which can be processed by a test-framework.

> 
> Tests that are checking new features (as opposed to bugs) should
> normally be able to check via "lctl get_param
> {mdc,osc}.*.connect_flags" output whether the server supports a given
> feature or not.

But situation when you are executing new tests on a old server could be
when you install in old lusre new tests. Oleg described below situation
when it is pretty hard to execute new tests(2.x) on old clients (1.8.x).

> 
>> The issue of running older release against a newer one is a real
>> one, but the truth is, when you run e.g. 1.8 vs 2.x, it's not just
>> the tests that are different, the init code is different too, so
>> it's not just a matter of separating tests subdir in its own
>> repository.

Oleg,
i'm answering there because You are in 'To'

I used term "test-framework" for init code, and I agree with you about
reasons. My tests separating idea is mostly not for code tree but for
logical separating, mostly in build,dependency and versioning( but
separating in code tree force to do it too).

I think, it will be good to have lusre_tests version 1.2.3 and set on
any lustre version. I think it can be interesting also for developers
who do fixes for old or his own branches to simply get new tests ready
for them.


>>  On our side we just note known broken tests for such
>> configurations and ignore the failures for the lack of better
>> solution.

Could you please publish the list?

> 
> As mentioned earlier - the presence of known failing tests causes
> confusion, and it would be better to annotate these tests in a clear
> manner by skipping them instead of just knowing that they will fail.
> 
>>> Different test cases, ended with letter(f.e. 130c),  have an
>>> different idea of dependencies. Some test cases have dependences
>>> to previous test cases, some don't have.
>> 
>> Ideally dependencies should be eliminated (in my opinion, anyway).
> 
> Agreed - all of the sub-tests should be able to run independently,
> even though they are normally run in order.

Maybe it is a good idea to define and publish rules like this:
1) test(test scenario) must have only number name (1,2,3..110...999)
2) test cases (test step) must have number+char index (1f,2,b...99c)

Test can be executed via ONLY.
Test cases can be execute only as part of test.
Tests must be independent.
Test cases can have dependencies.
Test define init, cleanup which are executing before and after test
cases (not before-after very test case but full group).

I think, these rules can somehow fix current situation with dependences
without many changes in tests.

-- 
Thanks,
	Roman
