From: Roman Grigoryev <Roman_Grigoryev@xyratex.com>
Date: Wed, 16 May 2012 17:57:24 +0400
Subject: [Lustre-devel] [more info] [Twg] Separated test execution
In-Reply-To: <4FB17224.1050105@xyratex.com>
References: <4FB17224.1050105@xyratex.com>
Message-ID: <4FB3B244.7080309@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,

I did (wit Alexanders help) 2 test executions on our latest lustre build
with limited set of test suites. *

First tests execution*: executing all tests with with ONLY keyword
one-by-one.

*Second execution*: executing all tests with with ONLY keyword
one-by-one and reformat lustre partition
(/usr/lib64/lustre/tests/llmountcleanup.sh and FORMAT=yes sh
/usr/lib64/lustre/tests/llmount.sh).

With these executions ways we should detect all tests dependencies
(exclude false pass, but this it other problem).

I prepared table with results for both executions and differences
between them.

Crossed tests - tests which are in ALWAYS_EXLUDED list.
 
So, it is 15 test which was failed with ONLY/ ONLY+REFORMAT.
Test  replay-single.44a.test  is killed by timeout, and can be excluded
from this list.
Tests sanity-quota.18b and sanity.129 failed because end of space(and
looks like formatting fix it).
So, 12 test have dependencies and should be fixed.  I think this is good
news.

 suite 	 with reformat 	 without reformat
	 diff
 sanity 	 
sanity.200h.test  	
	
sanity.200c.test 	
	
sanity.201b.test
	
	
sanity.200d.test
	
	
sanity.51c.test
	
	
sanity.42d.test
	
	
sanity.201c.test 	
	
sanity.200b.test 

	 
sanity.201b.test 	
	
sanity.200d.test 	
	
sanity.51c.test 	
	
sanity.42d.test 	
	
sanity.129.test 	
	
sanity.201c.test 

	 +200h
 +200c
 +200b
 -129
 sanityn 	 
 sanityn.14b.test
	
	
 sanityn.1b.test  	
	
 sanityn.1c.test  	
	
 sanityn.28.test  	
	
 sanityn.29.test

	 
 sanityn.14b.test
	
	
 sanityn.1b.test  	
	
 sanityn.1c.test  	
	
 sanityn.28.test  	
	
 sanityn.29.test 

	 no diff
 sanity-quota 	 none 	 sanity-quota.18b.test
	 -18b
 conf-sanity 	 none 	 none 	 no diff
 ost-pools
	 none 	 none 	 no diff
 lustre-rsync-test 	 none 	 none 	 no diff
 insanity 	 insanity.10.test
	 insanity.10.test
	 no diff
 replay-vbr 	 none 	 none 	 no diff
 replay-dual 	 none 	 none 	 no diff
 replay-ost-single 	 none 	 none 	 no diff
 recovery-small 	 
 recovery-small.3.test
	
	
 recovery-small.5.test 	
	
 recovery-small.52.test 	
	
 recovery-small.2.test 

	 
recovery-small.3.test
	
	
 recovery-small.5.test 	
	
 recovery-small.52.test 	
	
 recovery-small.2.test 

	 no diff
 replay-single 	 replay-single.44a.test
	 replay-single.44a.test
	 no diff


Thanks,
            Roman


On 05/15/2012 12:59 AM, Alexander Lezhoev wrote:
> Hi there,
>
> Let me raise the question about Lustre tests separated execution.
> We've discussed this problem already, but I'd like to clear up some
> details.
>
> Usually we run all tests sequentially, but in the automation tool we
> are using we need to run tests separately, with ONLY parameter. This
> allows us to have full control over the test execution: terminate hung
> tests by timeout or restore environment in case of the file system
> damage. At the moment some of tests are designed to be run sequentially.
>
> By our estimation, there are about 30 tests need for the  improvement.
> If we settle this question, we can significantly improve
> test-framework automation potential.
> Please share your opinions about this question and help to make a
> decision about it.
> The questions are
>
>  1. Do we want to have an ability to run each test independently?
>  2. What is more acceptable - unite sequential tests into complex ones
>     or supplement exists test with additional code steps?   
>
>
>
> Some technical details:
>
> Typical problem is sanityn test_1
>
> test_1a() {
>    touch $DIR1/f1
>    [ -f $DIR2/f1 ] || error
> }
> run_test 1a "check create on 2 mtpt's =========================="
>
> test_1b() {
>    chmod 777 $DIR2/f1
>    $CHECKSTAT -t file -p 0777 $DIR1/f1 || error
>    chmod a-x $DIR2/f1
> }
> run_test 1b "check attribute updates on 2 mtpt's ==============="
>
> test_1c() {
>    $CHECKSTAT -t file -p 0666 $DIR1/f1 || error
> }
> run_test 1c "check after remount attribute updates on 2 mtpt's ="
>
> test_1d() {
>    rm $DIR2/f1
>    $CHECKSTAT -a $DIR1/f1 || error
> }
> run_test 1d  "unlink on one mountpoint removes file on other ===="
>
>
> They cannot be run separately, because the next index uses the code of
> previous one. This means all tests should be run in groups of letter
> indexes, or they should be refactored to run independently.
>
> Some of tests have been already refactored to run "letters"
> separately, but we have to make a rule which we should follow and use
> for further refactoring.
> There are three decisions we can take about this situation
>
>   * Join the code of all test steps into single test with
>     corresponding number. So we will have one test_1 instead of
>     test_1a .. test_1d in the described case.
>   * Move the code of steps to corresponding functions which will be
>     called from each step. In other words the next indexed test will
>     duplicate some functionality of previous one.
>   * Do nothing and decide that "letters" mustn't be executed
>     independently, but only in "number" group.
>
>
> The first variant could be implemented as follows.
>
> test_1() {
>
> touch $DIR1/f1
>
> [ -f $DIR2/f1 ] || error "check create on 2 mtpt's failed"
>
> chmod 777 $DIR2/f1
>
> $CHECKSTAT -t file -p 0777 $DIR1/f1 || error "check attribute updates
> on 2 mtpt's failed"
>
> chmod a-x $DIR2/f1
>
> $CHECKSTAT -t file -p 0666 $DIR1/f1 || error "check after remount
> attribute updates on 2 mtpt's failed"
>
> rm $DIR2/f1
>
> $CHECKSTAT -a $DIR1/f1 || error "unlink on one mountpoint removes file
> on other failed"
>
> }
> run_test 1 "check attributes updates on 2 mtpt's"
>
> This approach has disadvantage that such kind of refactoring will lead
> to reduction of test numbering and it will hard to work with
> regression history of the refactored tests.
> The second case of refactoring can look like this:
>
> test_1a() {
>    test_1_create
> }
> run_test 1a "check create on 2 mtpt's =========================="
>
> test_1b() {
>    test_1_create
>    test_1_check_attr
> }
> run_test 1b "check attribute updates on 2 mtpt's ==============="
>
> test_1c() {
>    test_1_create
>    test_1_check_attr
>    test_1_check_attr2
> }
> run_test 1c "check after remount attribute updates on 2 mtpt's ="
>
> test_1d() {
>    test_1_create
>    test_1_check_attr
>    test_1_check_attr2
>    test_1_unlink
> }
> run_test 1d  "unlink on one mountpoint removes file on other ===="
>
> I've omitted functions code - their content is obvious.
> This disadvantage of this approach --- summary increase of tests
> run-time (the next test duplicates code of previous one). But the
> necessity of all these tests is doubtful here, because the last one
> includes first three tests.
>
> Very similar situation is for recovery-small 1, 2, 3 and 4, 5.
>
> test_1() {
> drop_request "mcreate $DIR/f1" || return 1
> drop_reint_reply "mcreate $DIR/f2" || return 2
> }
> run_test 1 "mcreate: drop req, drop rep"
>
> test_2() {
> drop_request "tchmod 111 $DIR/f2"  || return 1
> drop_reint_reply "tchmod 666 $DIR/f2"  || return 2
> }
> run_test 2 "chmod: drop req, drop rep"
>
> test_3() {
> drop_request "statone $DIR/f2" || return 1
> drop_reply "statone $DIR/f2"   || return 2
> }
> run_test 3 "stat: drop req, drop rep"
>
> These three tests are actually steps of a single test scenario,
> because they work with the results of previous ones.
>
> We can separate these tests:
>
> test_1() {
>    test_1_mcreate
> }
> run_test 1 "mcreate: drop req, drop rep"
>
> test_2() {
>    test_1_mcreate
>    test_2_chmod
> }
> run_test 2 "chmod: drop req, drop rep"
>
> test_3() {
>    test_1_mcreate
>    test_3_stat
> }
> run_test 3 "stat: drop req, drop rep"
>
> or join them into one and remove test_2 and test_3.
>
> test_1() {
>    drop_request "mcreate $DIR/f1"  || return 1
>    drop_reint_reply "mcreate $DIR/f2"    || return 2
>    drop_request "tchmod 111 $DIR/f2"  || return 3
>    drop_reint_reply "tchmod 666 $DIR/f2"    || return 4
>    drop_request "statone $DIR/f2" || return 5
>    drop_reply "statone $DIR/f2"   || return 6
> }
> run_test 1 "mcreate, chmod,stat: drop req, drop,req"
>
>
> Another big example are sanity tests 200 and 201. Here is the part of
> the resulting code after refactoring, so we can separately run each
> letter index:
>
> test_200a() {
>   test_200_create_pool
>   test_201_remove_pool
> }
> run_test 200a "Create new pool =========================================="
>
> test_200b() {
>   test_200_create_pool
>   test_200_add_targets
>   test_201_remove_all_targets
>   test_201_remove_pool
> }
>
> . . .
>
> test_201b() {
>   test_200_create_pool
>   test_200_add_targets
>   test_200_dir_set_pool
>   test_200_check_dir_pool
>   test_200_check_file_alloc
>   test_200_create_files
>   test_200_create_relative_path_files
>   test_201_remove_all_targets
>   test_201_remove_pool
> }
> run_test 201b "Remove all targets from a pool =========================="
>
> test_201c() {
>   test_200_create_pool
>   test_201_remove_pool
> }
> run_test 201c "Remove a pool ============================================"
>
>
> We have to include cleanup steps here to make possible to run letter
> indexes independently. With that cleanup steps, 200a and 201c became
> absolutely equal and need to be reduced. Same situation is for 200h
> and 201b.
>
>
>
> Sorry for so long email and thanks to Kyr
> (Kyrylo_Shatskyy at xyratex.com) for it's preparing.
>
> -- 
> Alexander Lezhoev.
> Morpheus test team.
> Xyratex.
>
>
>
> _______________________________________________
> twg mailing list
> twg at lists.opensfs.org
> http://lists.opensfs.org/listinfo.cgi/twg-opensfs.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120516/fa05b5c1/attachment.htm>
