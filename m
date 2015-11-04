From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 4 Nov 2015 01:43:03 +0000
Subject: [lustre-devel] [patch] staging: lustre: remove unused variable
Message-ID: <D25E8C0E.1180A2%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/11/03, 15:38, "Simmons, James A." <simmonsja@ornl.gov> wrote:

>>The "->lr_lvb_data" struct member is never used.  Delete it.
>>
>>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>---
>>I have compile tested this.  I looked through the history and it seems
>>to never have been used.  I wonder if we can remove the locking as well.
>
>This is used by the quota and ofd layer which are both server side.

When the server code is merged upstream this can be added to a union that
contains only server-side data that overlaps with a union containing only
client-side data.  For now it is fine to remove from the kernel.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
