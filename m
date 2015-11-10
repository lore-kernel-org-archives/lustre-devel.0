From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 10 Nov 2015 00:46:56 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Handle nodemask on
	UMP	machines
In-Reply-To: <20151109111939.GB3868@sudip-pc>
References: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
	<1447000500-29427-2-git-send-email-jsimmons@infradead.org>
	<20151109111939.GB3868@sudip-pc>
Message-ID: <9bac5dac537b42d89c5bd7e88ed31f80@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>On Sun, Nov 08, 2015 at 11:34:55AM -0500, James Simmons wrote:
>> For UMP and SMP machines the struct cfs_cpt_table are
>> defined differently. In the case handled by this patch
>> nodemask is defined as a integer for the UMP case and
>> as a pointer for the SMP case. This will cause a problem
>> for ost_setup which reads the nodemask directly. Instead
>> we create a UMP version of cfs_cpt_nodemask and use that
>> in ost_setup.
>> 
>> Signed-off-by: James Simmons <uja.ornl@gmail.com>
>> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4199
>> Reviewed-on: http://review.whamcloud.com/9219
>> Reviewed-by: Liang Zhen <liang.zhen@intel.com>
>> Reviewed-by: Li Xi <pkuelelixi@gmail.com>
>> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
>
>Signed-off-by: and Reviewed-by: tags entered two times. Once here.
 
It is one of those rare situations where two patches are need together.
It would be nice to be able to preserve the reviewers for each one.
