From: Roman Grigoryev <Roman_Grigoryev@xyratex.com>
Date: Fri, 30 Mar 2012 11:40:16 +0400
Subject: [Lustre-devel] [Twg] your opinion about  testing  improvements
In-Reply-To: <4F745E90.2000001@xyratex.com>
References: <4F745E90.2000001@xyratex.com>
Message-ID: <4F756360.1000108@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

(Sorry for cross posting, I haven't get answers in twg).
Hi all,

I'm working in testing team  in Xyratex.

After some time which I(and our team)  have spent on testing and
automation activities I would like try to ask community opinion about
two problems and suggestion in testing. This not closed list of testing
problems but I think it is good enough for start discussion.

Problem 1

Currently Lustre and test are living in one code space and build in one
time,and often have specific dependencies between test and code.

This situation directly affect

1) interoperability testing between different version. (because testing
is started from client which have different test framework then server
and client remotely execute test framework as their own. just copying
tests for equalization could not work with big difference between versions)

2) it is not simple execute(especially in automation) testing for test.
F.e. a bug is fixed, the test on it added. Executing the test on an old
revision(probably on a previous release) should show failed test result.
But with big difference between versions where fixed and where execute
test-framework can fail to start.

Possible solution: split Lustre and lustre tests in  code and  build
levels. It means that lustre and tests will not be connected on code
revision, only by logic, f.e. via keywords. Also should be added in same
time an abstraction level in test framework which allows to execute
lustre utils from different version of lustre.



Problem 2

(to avoid term problems, I call there: sanity = test suite, 130 = test,
130c and 130a = test cases)

Different test cases, ended with letter(f.e. 130c),  have an different
idea of dependencies. Some test cases have dependences to previous test
cases, some don't have.

All they now can be executed with "ONLY" parameter and all they have
separated item in result yaml file as just separated tests( which
doesn't have test cases ended with letter, f.e. sanity 129). Also, tests
which have testcases and don't have their own body can be execute  with
ONLY parameter( but doesn't have their special result).

So, logically, all test which can be execute via using ONLY must be not
depended to other tests. But we have test which depended. Moreover, some
developers prefer to consider testcases as step of full one test.

What is entities which I call "testcases" and "test" from your point of
view?

Answer of this question affect automated test execution and test
development, and maybe ask some test-framework changes.


-- 
Thanks,
	Roman
