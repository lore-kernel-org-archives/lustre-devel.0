From: Oleg Drokin <green@whamcloud.com>
Date: Sun, 1 Apr 2012 23:08:42 -0400
Subject: [Lustre-devel] [Twg] your opinion about  testing  improvements
In-Reply-To: <4F756360.1000108@xyratex.com>
References: <4F745E90.2000001@xyratex.com> <4F756360.1000108@xyratex.com>
Message-ID: <8F4579BA-FE5F-46C3-AC95-998E1195BD89@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Mar 30, 2012, at 3:40 AM, Roman Grigoryev wrote:
> 2) it is not simple execute(especially in automation) testing for test.
> F.e. a bug is fixed, the test on it added. Executing the test on an old
> revision(probably on a previous release) should show failed test result.
> But with big difference between versions where fixed and where execute
> test-framework can fail to start.

I am not quite sure why would you want to constantly fail a test that is known not to work with a particular release due to a missing bugfix.
I think it's enough if a developer (or somebody else) runs the test manually once on an unfixed codebase to make sure the test does without the fix.

The issue of running older release against a newer one is a real one, but the truth is, when you run e.g. 1.8 vs 2.x, it's not just the tests that are different, the init code is different too, so it's not just a matter of separating tests subdir in its own repository.
On our side we just note known broken tests for such configurations and ignore the failures for the lack of better solution.

> Different test cases, ended with letter(f.e. 130c),  have an different
> idea of dependencies. Some test cases have dependences to previous test
> cases, some don't have.

Ideally dependencies should be eliminated (in my opinion, anyway).

Bye,
    Oleg
--
Oleg Drokin
Senior Software Engineer
Whamcloud, Inc.
