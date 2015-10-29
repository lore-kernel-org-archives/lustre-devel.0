From: Simmons, James A. <simmonsja@ornl.gov>
Date: Thu, 29 Oct 2015 15:44:59 +0000
Subject: [lustre-devel] [PATCH 09/10] staging: lustre: fix remaining
 checkpatch issues for libcfs_hash.h
In-Reply-To: <D256AA29.116816%andreas.dilger@intel.com>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
	<1446051271-25189-10-git-send-email-jsimmons@infradead.org>
	<D256AA29.116816%andreas.dilger@intel.com>
Message-ID: <34f03ffe2c734f2d80bc6d5b1478b82d@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
>>b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
>>index 5df8ba2..563b2b4 100644
>>--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
>>+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
>>@@ -62,7 +62,8 @@
>> /** disable debug */
>> #define CFS_HASH_DEBUG_NONE	0
>> /** record hash depth and output to console when it's too deep,
>>- *  computing overhead is low but consume more memory */
>>+ *  computing overhead is low but consume more memory
>>+ */
>
>Typically, multi-line comments have the leading /* on a separate line
>from the first line of text.  If you are changing all these comments
>you may as well make it consistent with the kernel style.

Fixed for next patch series.
