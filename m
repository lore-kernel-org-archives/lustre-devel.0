From: Luis de Bethencourt <luisbg@osg.samsung.com>
Date: Wed, 15 Jun 2016 21:15:57 +0100
Subject: [lustre-devel] [PATCH 0/8] Lustre: Multiple assignments removal.
In-Reply-To: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
References: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
Message-ID: <5761B77D.5090603@osg.samsung.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On 10/06/16 03:35, Oleg Drokin wrote:
> These patches remove multiple assignments in Lustre, that makes
> checkpatch (somewhat understandably) unhappy.
> 
> Nathaniel Clark (8):
>   staging/lustre/osc: Fix Multiple Assignment Warnings
>   staging/lustre/fid: Fix Multiple Assignments
>   staging/lustre/ldlm: Fix Multiple Assignments
>   staging/lustre/llite: Fix Multiple Assignments
>   staging/lustre/lov: Fix Multiple Assignments
>   staging/lustre/obdclass: Fix Multiple Assignments
>   staging/lustre/ptlrpc: Fix Multiple Assignments
>   staging/lustre/lmv: Fix Multiple Assignments
> 
>  drivers/staging/lustre/lustre/fid/fid_request.c     |  6 ++++--
>  drivers/staging/lustre/lustre/ldlm/ldlm_lib.c       |  3 ++-
>  drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c     |  8 +++++---
>  drivers/staging/lustre/lustre/llite/llite_lib.c     |  3 ++-
>  drivers/staging/lustre/lustre/llite/namei.c         |  3 ++-
>  drivers/staging/lustre/lustre/llite/vvp_io.c        |  3 ++-
>  drivers/staging/lustre/lustre/lmv/lmv_obd.c         |  3 +--
>  drivers/staging/lustre/lustre/lov/lov_obd.c         |  9 ++++-----
>  drivers/staging/lustre/lustre/obdclass/llog.c       |  6 ++++--
>  drivers/staging/lustre/lustre/osc/osc_cache.c       |  6 ++++--
>  drivers/staging/lustre/lustre/osc/osc_io.c          | 12 ++++++++----
>  drivers/staging/lustre/lustre/osc/osc_lock.c        |  3 ++-
>  drivers/staging/lustre/lustre/osc/osc_request.c     |  6 ++++--
>  drivers/staging/lustre/lustre/ptlrpc/client.c       |  6 ++++--
>  drivers/staging/lustre/lustre/ptlrpc/import.c       |  3 ++-
>  drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c |  3 ++-
>  drivers/staging/lustre/lustre/ptlrpc/pinger.c       |  3 ++-
>  drivers/staging/lustre/lustre/ptlrpc/sec_null.c     |  3 ++-
>  18 files changed, 56 insertions(+), 33 deletions(-)
> 

Hi,

Documentation/CodingStyle says (in line 65):
"Don't put multiple assignments on a single line either.  Kernel coding style
is super simple.  Avoid tricky expressions."

This patch set looks good.
Luis
