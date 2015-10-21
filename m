From: Patrick Farrell <paf@cray.com>
Date: Wed, 21 Oct 2015 13:42:18 +0000
Subject: [lustre-devel] [PATCH] staging/lustre: move IT_* definitions to
 lustre_idl.h
In-Reply-To: <D24D0D4E.26FC%jevans@cray.com>
References: <20151020220201.GA6065@lusbld01.us.cray.com>
	<DB0C8A206669AC40B1C4E52A8584A6F614D17E39@CFWEX01.americas.cray.com>,
	<D24D0D4E.26FC%jevans@cray.com>
Message-ID: <DB0C8A206669AC40B1C4E52A8584A6F614D17EA6@CFWEX01.americas.cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ah, OK.

Thank you, Ben, Oleg.
________________________________________
From: Ben Evans
Sent: Wednesday, October 21, 2015 8:37 AM
To: Patrick Farrell; Ben Evans; lustre-devel at lists.lustre.org
Subject: Re: [lustre-devel] [PATCH] staging/lustre: move IT_* definitions to lustre_idl.h

Yep, see the discussion here:  http://review.whamcloud.com/#/c/16228/

On 10/20/15, 8:41 PM, "Patrick Farrell" <paf@cray.com> wrote:

>Do you know what the removed comment about being coherent with namei.h
>means or once meant?  I took a look and can't see anything that
>corresponds now, but I'd feel more comfortable if I knew for sure what
>that comment meant...
>
>- Patrick
>________________________________________
>From: lustre-devel [lustre-devel-bounces at lists.lustre.org] on behalf of
>Ben Evans [bevans at cray.com]
>Sent: Tuesday, October 20, 2015 5:02 PM
>To: lustre-devel at lists.lustre.org
>Subject: [lustre-devel] [PATCH] staging/lustre: move IT_* definitions to
>      lustre_idl.h
>
>Put IT_* definitions into an enum, as they're sent over the wire,
>adjust calls, print statements, etc. to use the new enum.
>
>Signed-off-by: Ben Evans <bevans@cray.com>
>---
> .../lustre/lustre/include/lustre/lustre_idl.h      |   18
>++++++++++++++++++
> drivers/staging/lustre/lustre/include/lustre_dlm.h |    2 +-
> drivers/staging/lustre/lustre/include/obd.h        |   16
>----------------
> drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    2 +-
> 4 files changed, 20 insertions(+), 18 deletions(-)
>
>diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>index ac78dbc..646c095 100644
>--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>@@ -2782,6 +2782,24 @@ union ldlm_gl_desc {
>
> void lustre_swab_gl_desc(union ldlm_gl_desc *);
>
>+enum ldlm_intent_flags {
>+       IT_OPEN        = 0x00000001,
>+       IT_CREAT       = 0x00000002,
>+       IT_OPEN_CREAT  = 0x00000003,
>+       IT_READDIR     = 0x00000004,
>+       IT_GETATTR     = 0x00000008,
>+       IT_LOOKUP      = 0x00000010,
>+       IT_UNLINK      = 0x00000020,
>+       IT_TRUNC       = 0x00000040,
>+       IT_GETXATTR    = 0x00000080,
>+       IT_EXEC        = 0x00000100,
>+       IT_PIN         = 0x00000200,
>+       IT_LAYOUT      = 0x00000400,
>+       IT_QUOTA_DQACQ = 0x00000800,
>+       IT_QUOTA_CONN  = 0x00001000,
>+       IT_SETXATTR    = 0x00002000,
>+};
>+
> struct ldlm_intent {
>        __u64 opc;
> };
>diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h
>b/drivers/staging/lustre/lustre/include/lustre_dlm.h
>index 3552546..af46f36 100644
>--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
>+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
>@@ -1017,7 +1017,7 @@ extern struct obd_ops ldlm_obd_ops;
>
> extern char *ldlm_lockname[];
> extern char *ldlm_typename[];
>-char *ldlm_it2str(int it);
>+const char *ldlm_it2str(enum ldlm_intent_flags it);
>
> /**
>  * Just a fancy CDEBUG call with log level preset to LDLM_DEBUG.
>diff --git a/drivers/staging/lustre/lustre/include/obd.h
>b/drivers/staging/lustre/lustre/include/obd.h
>index 9ad8c26..f731f51 100644
>--- a/drivers/staging/lustre/lustre/include/obd.h
>+++ b/drivers/staging/lustre/lustre/include/obd.h
>@@ -995,22 +995,6 @@ enum obd_cleanup_stage {
>
> struct lu_context;
>
>-/* /!\ must be coherent with include/linux/namei.h on patched kernel */
>-#define IT_OPEN     (1 << 0)
>-#define IT_CREAT    (1 << 1)
>-#define IT_READDIR  (1 << 2)
>-#define IT_GETATTR  (1 << 3)
>-#define IT_LOOKUP   (1 << 4)
>-#define IT_UNLINK   (1 << 5)
>-#define IT_TRUNC    (1 << 6)
>-#define IT_GETXATTR (1 << 7)
>-#define IT_EXEC     (1 << 8)
>-#define IT_PIN      (1 << 9)
>-#define IT_LAYOUT   (1 << 10)
>-#define IT_QUOTA_DQACQ (1 << 11)
>-#define IT_QUOTA_CONN  (1 << 12)
>-#define IT_SETXATTR (1 << 13)
>-
> static inline int it_to_lock_mode(struct lookup_intent *it)
> {
>        /* CREAT needs to be tested before open (both could be set) */
>diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
>b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
>index cd340fc..f3b197a 100644
>--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
>+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
>@@ -123,7 +123,7 @@ void ldlm_convert_policy_to_local(struct obd_export
>*exp, ldlm_type_t type,
>        convert(wpolicy, lpolicy);
> }
>
>-char *ldlm_it2str(int it)
>+const char *ldlm_it2str(enum ldlm_intent_flags it)
> {
>        switch (it) {
>        case IT_OPEN:
>--
>1.6.5.6
>
>_______________________________________________
>lustre-devel mailing list
>lustre-devel at lists.lustre.org
>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
