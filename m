From: Roman Grigoryev <Roman_Grigoryev@xyratex.com>
Date: Tue, 03 Apr 2012 10:07:00 +0400
Subject: [Lustre-devel] your opinion about testing improvements (was
 Lustre-devel Digest, Vol 72, Issue 17)
In-Reply-To: <4F7A43D1.5000209@whamcloud.com>
References: <mailman.1.1333130401.17602.lustre-devel@lists.lustre.org>
	<4F7A43D1.5000209@whamcloud.com>
Message-ID: <4F7A9384.80707@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Chris,
Thank you for answer ( I have cut part of my original message):

>> Problem 1
>>
>> Currently Lustre and test are living in one code space and build in one
>> time,and often have specific dependencies between test and code.
......

>> Possible solution: split Lustre and lustre tests in  code and  build
>> levels. It means that lustre and tests will not be connected on code
>> revision, only by logic, f.e. via keywords. Also should be added in same
>> time an abstraction level in test framework which allows to execute
>> lustre utils from different version of lustre.
> The situation here is exactly the same as exists with the source code.

> When we run interop tests the test system runs test scripts belonging to
> the server version against those belonging to the client version. So we
> might use 1.8.7 client scripts against 2.2 server scripts. These scripts
> need to inter-operate in exactly the same way that the Lustre source
> code itself needs to interoperate.

Yes, it is. But I don't see why we should use old test base for
interoperability testing? Between 1.8.7 and 2.x tests was fixed and also
as test framework was changed. For getting same test coverage for old
features we should backport new fixes in test to old (maybe already
frozen) code.
Also, as results, we have different tests sets for compatibility
testing. For 1.8.7 it will one, for 2.1 - other. Only a part of
differences shows difference between code base for one feature set.
(F.e. we see on special 1.8.7 branch failures which already fixed in 2.x
code.)


> 
> If people find cases where this does not happen then they raise bugs
> against Lustre and these are fixed using the same processes as any other
> Lustre bug. This means people across the community investing effort to
> rectify the incompatibilities and then posting patches for review, test
> and inclusion in the product. Of course in a perfect world we would be
> back at the point where 1.8.7 and 2.x forked and never allow the
> interoperability issues in the test scripts to creep in, but the reality
> is the issues do exist and effort does needs to be spent resolving them.
> I am 100% sure that the resolution of the relatively few
> incompatibilities is infinitely easier than attempting to take the 1.8,
> 2.1 and 2.2 test scripts and produce an independent one size fits all
> solution.
> 

I agree that there is a lot of work on test framework abstraction layer
also on adding simple filtering procedure and setting keywords.

But having one test base give us good possibility just setup an actual
test package on all nodes and have somehow predict executed test set.
Also, in this letter below, we discuss test/test framework changes. If
we will have separated tests between version package then benefits from
new tests descriptors we be accessible for all previous system too. In
other case we could create incompatible improvements.


> We currently track each failing test in Jira, see here
> http://jira.whamcloud.com/browse/LU-1193  for an example. If others find
> issues in their testing then they should create Jira issues to track
> them and if possible post patches to resolve them.

Thanks for this link. Do you have any keyword or attribute for
interoperability failures?

> 
>>
>>
>> Problem 2
>>
>> (to avoid term problems, I call there: sanity = test suite, 130 = test,
>> 130c and 130a = test cases)
>>

...

>> Answer of this question affect automated test execution and test
>> development, and maybe ask some test-framework changes.
>>
> I think you highlight a very good point here that we don't really know
> enough about the test contents, their prerequisites or other
> dependencies. I would suggest that many attempts have been made over the
> years to use naming conventions, numeric ordering or other similar
> mechanisms to track such behaviour.
> 
> What we need to make sense of the 1000+ test cases we have is an
> extensible knowledge-base of information that can grow overtime to
> become a rich source of information that can be used to allow automated
> systems as well as developers to confidently use the tests in the most
> flexible way possible.
> 
> Because of the nature of Lustre we need to find a way that keeps this
> knowledge within the public domain, provides for use to expand the range
> of things we store about each test and provides for both people and
> machines to access it with equal ease.
> 
> One reasonable proposal is to add a comment block at the start of each
> test script and subtest within that script that lists the test name,
> short and long description that includes what the test is supposed to be
> doing, what bug (if any) it was originally added for, what part of the
> code it is intended to cover, prerequisites (filesystem initialization,
> min/max number of clients, OSTs, MDTs it can test with, etc) in a
> machine readable format that it not only documents the test today but
> that can be expanded in the future.

I agree, it is very important to separating meta information and test body.
Internally in Xyratex, we use external scripts and descriptors which
somehow add same possibility(per-test timeouts, keywords...).

> 
> Once we have an agreement on an initial format for this comment block,
> the development community can work to populate it for each subtest and
> improve the understanding and usefulness of all existing tests.

I absolutely agree that we need agreement to start any work on test
improvements. How can we initiate this process? Maybe good first step is
creating glossary to use and terms and based on these terms fix tests?

Also, what do you think about a possible simple solutions for decreasing
dependence problem which is currently pretty painful for us:

1) test(test scenario) must have only number name (1,2,3..110...999)
2) test cases (test step) must have number+char index (1f,2,b...99c)

Only Test can be executed via ONLY.
Test cases can be execute only as part of test.

Thanks,
	Roman
