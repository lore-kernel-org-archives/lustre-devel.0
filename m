From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Wed, 4 Apr 2012 14:24:01 -0700
Subject: [Lustre-devel] your opinion about testing improvements (was
	Lustre-devel Digest, Vol 72, Issue 17)
In-Reply-To: <4F7B0770.8050308@whamcloud.com>
References: <mailman.1.1333130401.17602.lustre-devel@lists.lustre.org>
	<4F7A43D1.5000209@whamcloud.com> <4F7A9384.80707@xyratex.com>
	<4F7B0770.8050308@whamcloud.com>
Message-ID: <73AED5C780AE05478241DB067651A92102F1091C@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Apr 3, 2012, at 7:21 AM, Chris Gearing wrote:

> On 03/04/2012 07:07, Roman Grigoryev wrote:
>> Hi Chris,
>> Thank you for answer ( I have cut part of my original message):
>>> When we run interop tests the test system runs test scripts belonging to
>>> the server version against those belonging to the client version. So we
>>> might use 1.8.7 client scripts against 2.2 server scripts. These scripts
>>> need to inter-operate in exactly the same way that the Lustre source
>>> code itself needs to interoperate.
>> Yes, it is. But I don't see why we should use old test base for
>> interoperability testing? Between 1.8.7 and 2.x tests was fixed and also
>> as test framework was changed. For getting same test coverage for old
>> features we should backport new fixes in test to old (maybe already
>> frozen) code.
>> Also, as results, we have different tests sets for compatibility
>> testing. For 1.8.7 it will one, for 2.1 - other. Only a part of
>> differences shows difference between code base for one feature set.
>> (F.e. we see on special 1.8.7 branch failures which already fixed in 2.x
>> code.)
>> 
> We don't have a single script because the tests are at times very 
> tightly coupled to the Lustre version. There were a lot of changes 
> between 1.8.x and 2.x and a lot of corresponding changes to the test 
> scripts. Where the tests are the same and bugs were found in the 2.x 
> test scripts these should have been backported to the 1.8.x test scripts 
> if this was not done then we should do it for inclusion into the 1.8.8 
> release.
> 
> The notion of making 'master' scripts work with with all versions is 
> obviously possible but it is a very significant task and given that the 
> scripts themselves are written in a language (sic) that does not provide 
> structure a single script strategy is likely to create many more 
> 'interoperability issues' than it fixes.
> 
> Also it's worth considering that we have best part of a 1000 discrete 
> changes, whenever a test is re-engineered the test itself must be proven 
> to detect failure as well as success. i.e. If someone produced a version 
> independent test set that passed all versions we would not know that the 
> process was a success, we would need to check that each re-engineered 
> test 'failed' appropriately for each Lustre version, this is a big task 
> that I doubt can be properly achieved in bash.
> 
> So in summary the best solution given what we have today is to back port 
> fixes to the test scripts as we back port fixes to the code. This is an 
> investment in time and requires the same discipline to test as we have 
> for coding. A single set of scripts that caters for all versions appears 
> I believe like an easy solution but actually would require huge 
> investment that would be better spent developing a modern test framework 
> and infrastructure that can support Lustre for the next ten years.

I agree on this last point -- is that something that OpenSFS should spearhead?
Roman has pointed out some of the limitations with the current test framework,
Robert Read has pointed out the poor/redundant coverage of many of the existing tests;
is it time to start from scratch?  Is there a more evolutionary approach we can/should use?


> 
>> 
>>>> 
>>>> Problem 2
>>>> 
>>>> (to avoid term problems, I call there: sanity = test suite, 130 = test,
>>>> 130c and 130a = test cases)
>>>> 
>> ...
>> 
>>>> Answer of this question affect automated test execution and test
>>>> development, and maybe ask some test-framework changes.
>>>> 
>>> I think you highlight a very good point here that we don't really know
>>> enough about the test contents, their prerequisites or other
>>> dependencies. I would suggest that many attempts have been made over the
>>> years to use naming conventions, numeric ordering or other similar
>>> mechanisms to track such behaviour.
>>> ...
>>> One reasonable proposal is to add a comment block at the start of each
>>> test script and subtest within that script that lists the test name,
>>> short and long description that includes what the test is supposed to be
>>> doing, what bug (if any) it was originally added for, what part of the
>>> code it is intended to cover, prerequisites (filesystem initialization,
>>> min/max number of clients, OSTs, MDTs it can test with, etc) in a
>>> machine readable format that it not only documents the test today but
>>> that can be expanded in the future.
>> I agree, it is very important to separating meta information and test body.
>> Internally in Xyratex, we use external scripts and descriptors which
>> somehow add same possibility(per-test timeouts, keywords...).
>> 
>>> Once we have an agreement on an initial format for this comment block,
>>> the development community can work to populate it for each subtest and
>>> improve the understanding and usefulness of all existing tests.
>> I absolutely agree that we need agreement to start any work on test
>> improvements. How can we initiate this process? Maybe good first step is
>> creating glossary to use and terms and based on these terms fix tests?
>> 
>> Also, what do you think about a possible simple solutions for decreasing
>> dependence problem which is currently pretty painful for us:
>> 
>> 1) test(test scenario) must have only number name (1,2,3..110...999)
>> 2) test cases (test step) must have number+char index (1f,2,b...99c)
>> 
>> Only Test can be executed via ONLY.
>> Test cases can be execute only as part of test.
> I don't think there is a problem with this simple solution in that it 
> does no harm as long as you applied any changes to all the branches that 
> are applicable. At the same time I will draft a possible meta data 
> format that includes the extensible metadata within the source in a way 
> that maximizes its value both today and in the future, we can then 
> review, revise and then agree that format on Lustre-Devel, although I'll 
> mail you privately so you can have input before that. It may actually be 
> the case that some work has occurred on this topic previously and if so 
> we can leverage that.
> 
> Thanks
> 
> Chris Gearing
> Sr. Software Engineer
> Quality Engineering
> Whamcloud Inc
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
