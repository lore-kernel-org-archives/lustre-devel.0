From: Andreas Dilger <adilger@whamcloud.com>
Date: Sun, 1 Apr 2012 23:33:00 -0600
Subject: [Lustre-devel] [Twg] your opinion about  testing  improvements
In-Reply-To: <8F4579BA-FE5F-46C3-AC95-998E1195BD89@whamcloud.com>
References: <4F745E90.2000001@xyratex.com> <4F756360.1000108@xyratex.com>
	<8F4579BA-FE5F-46C3-AC95-998E1195BD89@whamcloud.com>
Message-ID: <F264939C-663E-4A1E-A63A-211026EF6881@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-04-01, at 9:08 PM, Oleg Drokin wrote:
> On Mar 30, 2012, at 3:40 AM, Roman Grigoryev wrote:
>> 2) it is not simple execute(especially in automation) testing for test.
>> F.e. a bug is fixed, the test on it added. Executing the test on an old
>> revision(probably on a previous release) should show failed test result.
>> But with big difference between versions where fixed and where execute
>> test-framework can fail to start.
> 
> I am not quite sure why would you want to constantly fail a test that is known not to work with a particular release due to a missing bugfix.
> I think it's enough if a developer (or somebody else) runs the test manually once on an unfixed codebase to make sure the test does without the fix.

I think it makes sense to be able to skip a test that is failing for versions of Lustre older than X, for cases where the test is exercising some fix on the server.  We _do_ run interoperability tests and hit these failures, and it is much better to skip the test with a clear message instead of marking the test as failed.

Probably the easiest solution is for such tests to explicitly check the version of the server, with a new helper function like "skip_old_version" or similar.

Tests that are checking new features (as opposed to bugs) should normally be able to check via "lctl get_param {mdc,osc}.*.connect_flags" output whether the server supports a given feature or not.

> The issue of running older release against a newer one is a real one, but the truth is, when you run e.g. 1.8 vs 2.x, it's not just the tests that are different, the init code is different too, so it's not just a matter of separating tests subdir in its own repository.
> On our side we just note known broken tests for such configurations and ignore the failures for the lack of better solution.

As mentioned earlier - the presence of known failing tests causes confusion, and it would be better to annotate these tests in a clear manner by skipping them instead of just knowing that they will fail.

>> Different test cases, ended with letter(f.e. 130c),  have an different
>> idea of dependencies. Some test cases have dependences to previous test
>> cases, some don't have.
> 
> Ideally dependencies should be eliminated (in my opinion, anyway).

Agreed - all of the sub-tests should be able to run independently, even though they are normally run in order.


Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/
