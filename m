From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 4 Nov 2015 15:05:41 +0000
Subject: [lustre-devel] [PATCH v2 1/7] staging: lustre: remove white
 space in libcfs_hash.h
In-Reply-To: <20151104034607.GA12870@kroah.com>
References: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
	<1446484933-23571-2-git-send-email-jsimmons@infradead.org>
	<20151104034607.GA12870@kroah.com>
Message-ID: <e1ec3a1b2a6d435ba72d880e301cf3d1@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>On Mon, Nov 02, 2015 at 12:22:07PM -0500, James Simmons wrote:
>> Cleanup all the unneeded white space in libcfs_hash.h.
>> 
>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>> ---
>>  .../lustre/include/linux/libcfs/libcfs_hash.h      |  135 ++++++++++----------
>>  1 files changed, 70 insertions(+), 65 deletions(-)
>
>Doesn't apply, did I already queue up this series?

I did a second version of those patches. In one batch you will notice [PATCH v2].
The reason I did a second batch was to break up the "fix checkpatch issues" patch
in the first series. I was trying to behave :-)
