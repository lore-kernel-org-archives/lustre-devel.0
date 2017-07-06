From: Frans Klaver <fransklaver@gmail.com>
Date: Thu, 6 Jul 2017 09:23:53 +0200
Subject: [lustre-devel] [PATCH 8/8] Staging: lustre :lustre: include
 :lustre_compat.h: Prefer using the BIT macro
In-Reply-To: <1499325195-17466-1-git-send-email-rjdurga@gmail.com>
References: <1499325195-17466-1-git-send-email-rjdurga@gmail.com>
Message-ID: <CAH6sp9PuJ_zxK1D=t_i2aAeeNzaoUP+UqnGQC_Pin-QNgjJ7hg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jaya Durga <rjdurga@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, driverdevel <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, oleg.drokin@intel.com, andreas.dilger@intel.com, john.hammond@intel.com, bobijam@hotmail.com, Ingo Molnar <mingo@kernel.org>, lustre-devel@lists.lustre.org

On Thu, Jul 6, 2017 at 9:13 AM, Jaya Durga <rjdurga@gmail.com> wrote:
> Subject: Staging: lustre :lustre: include :lustre_compat.h: Prefer using the BIT macro

Don't overdo it ;-).

Subject: staging: lustre: lustre_compat.h: Prefer using the BIT macro

> Replace all instances of (1 << 27) with BIT(27) to fix
> checkpatch check messages

While it may technically be true that this one instance is every
instance of (1<<27) there is in lustre_compat.h, I must say I expected
a bigger patch when I saw "replace all instances".


> Signed-off-by: Jaya Durga <rjdurga@gmail.com>
> ---
>  drivers/staging/lustre/lustre/include/lustre_compat.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
> index da9ce19..686a251 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_compat.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
> @@ -43,7 +43,7 @@
>   * set ATTR_BLOCKS to a high value to avoid any risk of collision with other
>   * ATTR_* attributes (see bug 13828)
>   */
> -#define ATTR_BLOCKS    (1 << 27)
> +#define ATTR_BLOCKS    BIT(27)
>
>  #define current_ngroups current_cred()->group_info->ngroups
>  #define current_groups current_cred()->group_info->small_block
> --
> 1.9.1
>
> _______________________________________________
> devel mailing list
> devel at linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
