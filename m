From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 10 Nov 2015 00:44:48 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: export cfs_str2mask
In-Reply-To: <5F41E759-F653-4A35-B2E5-15544BCF4BD2@intel.com>
References: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
	<1447000500-29427-6-git-send-email-jsimmons@infradead.org>
	<5F41E759-F653-4A35-B2E5-15544BCF4BD2@intel.com>
Message-ID: <db7639785c8048ed966aca6908516797@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>> We need cfs_str2mask exported for our server code.
>> Even with the server code not available upstream
>> it would be nice to use the upstream code on Lustre
>> servers.
>> 
>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>> ---
>> .../staging/lustre/lustre/libcfs/libcfs_string.c   |    1 +
>> 1 files changed, 1 insertions(+), 0 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
>> index d40be53..05630f8 100644
>> --- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
>> +++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
>> @@ -111,6 +111,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
>> 	*oldmask = newmask;
>> 	return 0;
>> }
>> +EXPORT_SYMBOL(cfs_str2mask);
>
>If this is the case of it being used out of tree, I suspect a comment here to that effect would be
>useful, otherwise next person running a script to eliminate unused EXPORT_SYMBOLs would kill it again.

I will send another patch with comments not to remove the new code.
