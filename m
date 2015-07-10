From: Patrick Farrell <paf@cray.com>
Date: Fri, 10 Jul 2015 10:11:54 -0500
Subject: [lustre-devel] [PATCH] lustre/staging: remove unused MAY_
	constants
In-Reply-To: <20150710150931.GA29330@lusbld01.us.cray.com>
References: <20150710150931.GA29330@lusbld01.us.cray.com>
Message-ID: <559FE0BA.1060206@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Typo in the bug-ID URL.  httpd instead of hpdd.
On 07/10/2015 10:09 AM, Ben Evans wrote:
> Remove unused MAY_ constants from lustre_idl.h
>
> Intel-bug-ID: http://jira.httpd.intel.com/browse/LU-6450
> Reviewed-by: James Simmons <uja.ornl@gmail.com>
> Signed-off-by: Ben Evans <bevans@cray.com>
> ---
>   .../lustre/lustre/include/lustre/lustre_idl.h      |   24 ++++++++-----------
>   1 files changed, 10 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> index bea70cb..be1cbae 100644
> --- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> +++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
> @@ -2366,20 +2366,16 @@ extern void lustre_swab_mdt_rec_setattr (struct mdt_rec_setattr *sa);
>   					      */
>   #define MDS_OPEN_RELEASE   02000000000000ULL /* Open the file for HSM release */
>   
> -/* permission for create non-directory file */
> -#define MAY_CREATE      (1 << 7)
> -/* permission for create directory file */
> -#define MAY_LINK	(1 << 8)
> -/* permission for delete from the directory */
> -#define MAY_UNLINK      (1 << 9)
> -/* source's permission for rename */
> -#define MAY_RENAME_SRC  (1 << 10)
> -/* target's permission for rename */
> -#define MAY_RENAME_TAR  (1 << 11)
> -/* part (parent's) VTX permission check */
> -#define MAY_VTX_PART    (1 << 12)
> -/* full VTX permission check */
> -#define MAY_VTX_FULL    (1 << 13)
> +/*
> +#define UNUSED_MAY_CREATE	(1 << 7) create non-directory file
> +#define UNUSED_MAY_LINK		(1 << 8) create directory file
> +#define UNUSED_MAY_UNLINK	(1 << 9) delete from the directory
> +#define UNUSED_MAY_RENAME_SRC	(1 << 10) source's rename
> +#define UNUSED_MAY_RENAME_TAR	(1 << 11) target's rename
> +#define UNUSED_MAY_VTX_PART	(1 << 12) part (parent's) VTX check
> +#define UNUSED_MAY_VTX_FULL	(1 << 13) full VTX check
> +*/
> +
>   /* lfs rgetfacl permission check */
>   #define MAY_RGETFACL    (1 << 14)
>   
