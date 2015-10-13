From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 13 Oct 2015 22:42:22 +0000
Subject: [lustre-devel] [PATCH 0/7] staging: lustre: remove uses and
 definition of container_of0
In-Reply-To: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <D242E3F1.110E68%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/10/13, 16:19, "Aya Mahfouz" <mahfouz.saif.elyazal@gmail.com> wrote:

>container_of0 can be replaced by the Linux kernel macro container_of.
>The only difference is that container_of0 tries to evade type casting
>when the pointer is erroneous or null. All uses of container_of0 have
>been replaced by container_of and then the macro was removed in the last
>patch.

Thank you for your patch.  However, it should be noted that this blanket
replacement of container_of0() isn't necessarily safe.  If the caller isn't
explicitly checking for IS_ERR(ptr) or ptr == NULL then the container_of()
macro can transform the err/NULL pointer into another pointer that is
NOT err/NULL and cause the kernel to oops when the bad pointer is used,
even if there are later IS_ERR() or NULL checks.

I'm not against removing container_of0() completely, but not without a
clear review of the callers to determine whether err/NULL pointers are
not actually possible in this callpath, or explicit checks in the callers
for err/NULL pointers before container_of() is used.  Did you do that?

Cheers, Andreas

>Aya Mahfouz (7):
>  staging: lustre: lcommon_cl.c: replace container_of0 by container_of
>  staging: lustre: llite_nfs.c: replace container_of0 by container_of
>  staging: lustre: lu_object.c: replace container_of0 by container_of
>  staging: lustre: echo_client.c: replace container_of0 by container_of
>  staging: lustre: osc_io.c: replace container_of0 by container_of
>  staging: lustre: osc_object.c: replace container_of0 by container_of
>  staging: lustre: remove container_of0 and __container_of
>
> drivers/staging/lustre/include/linux/libcfs/libcfs.h | 11 -----------
> drivers/staging/lustre/lustre/lclient/lcommon_cl.c   | 10 +++++-----
> drivers/staging/lustre/lustre/llite/llite_nfs.c      |  2 +-
> drivers/staging/lustre/lustre/obdclass/lu_object.c   |  6 +++---
> drivers/staging/lustre/lustre/obdecho/echo_client.c  |  2 +-
> drivers/staging/lustre/lustre/osc/osc_io.c           |  4 ++--
> drivers/staging/lustre/lustre/osc/osc_object.c       |  2 +-
> 7 files changed, 13 insertions(+), 24 deletions(-)
>
>-- 
>2.4.2
>
>
>-- 
>Kind Regards,
>Aya Saif El-yazal Mahfouz
>


Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
