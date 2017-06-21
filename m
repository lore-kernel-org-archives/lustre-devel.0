From: Tordek <kedrot@gmail.com>
Date: Wed, 21 Jun 2017 04:24:08 -0300
Subject: [lustre-devel] [PATCH] staging/lustre: echo_client.c - fix
 sparse warning: cast removes address space of expression
In-Reply-To: <20170608053527.21599-1-kedrot@gmail.com>
References: <20170608053527.21599-1-kedrot@gmail.com>
Message-ID: <CAKUXR6MpyuJv=+SLaZjPV5YB_RpAfYAKkuZ0VW6HUP0gm3bdvA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi, List

I don't want to be a bother but should I be doing something different
when submitting patches? I know it's minor but it's a simple change
and it's received no response after two weeks; not even a rejection.

Cheers
--
Tordek

On 8 June 2017 at 02:35, Guillermo O. Freschi <kedrot@gmail.com> wrote:
> The function only cares about the value of the pointer, not the contents
> of the pointed-to data. Adding a `__force` annotation to the cast
> removes this warning.
>
> Signed-off-by: Guillermo O. Freschi <kedrot@gmail.com>
> ---
>  drivers/staging/lustre/lustre/obdecho/echo_client.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> index d4768311cf92..1757714c56a0 100644
> --- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
> +++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> @@ -1428,7 +1428,7 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
>         oa->o_valid &= ~OBD_MD_FLHANDLE;
>
>         /* OFD/obdfilter works only via prep/commit */
> -       test_mode = (long)data->ioc_pbuf1;
> +       test_mode = (__force long)data->ioc_pbuf1;
>         if (test_mode == 1)
>                 async = 0;
>
> --
> 2.11.0
>
