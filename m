From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 3 Jul 2018 21:46:56 +0000
Subject: [lustre-devel] [PATCH 18/18] lustre: update version to 2.8.99
In-Reply-To: <1530573875-20465-19-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>,
 <1530573875-20465-19-git-send-email-jsimmons@infradead.org>
Message-ID: <29BE954A-B97C-4EED-8CE0-70FD0B14AE9E@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

James, thanks for pushing up these patches.

Why not use 2.9.0? Are there still patches missing, or do you want this version to distinguish it from the actual 2.9.0 release?

Cheers, Andreas

> On Jul 2, 2018, at 17:36, James Simmons <jsimmons@infradead.org> wrote:
> 
> With the missing patches from the lustre 2.9 release merged
> upstream its time to update the upstream client's version.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h
> index 19c9135..1428fdd 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h
> @@ -2,10 +2,10 @@
> #define _LUSTRE_VER_H_
> 
> #define LUSTRE_MAJOR 2
> -#define LUSTRE_MINOR 6
> +#define LUSTRE_MINOR 8
> #define LUSTRE_PATCH 99
> #define LUSTRE_FIX 0
> -#define LUSTRE_VERSION_STRING "2.6.99"
> +#define LUSTRE_VERSION_STRING "2.8.99"
> 
> #define OBD_OCD_VERSION(major, minor, patch, fix)            \
>    (((major) << 24) + ((minor) << 16) + ((patch) << 8) + (fix))
> -- 
> 1.8.3.1
> 
