From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Sun, 8 Nov 2015 22:41:36 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: lproc_mgc: Remove
	unused function mgc_ir_state_seq_show
In-Reply-To: <1447002226-4462-1-git-send-email-shivanib134@gmail.com>
References: <1447002226-4462-1-git-send-email-shivanib134@gmail.com>
Message-ID: <CAKHNQQGpPvyqMjwdKApNTgxemahhyzd0p5LqGQ_AO5-xwyzdEQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Nov 8, 2015 at 10:33 PM, Shivani Bhardwaj <shivanib134@gmail.com> wrote:
> Remove the function mgc_ir_state_seq_show() as it is not
> referenced/called anywhere.
>
> Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
> ---
>  drivers/staging/lustre/lustre/mgc/lproc_mgc.c | 5 -----
>  1 file changed, 5 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
> index 8d5bc5a..ad6a7d9 100644
> --- a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
> +++ b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
> @@ -48,11 +48,6 @@ LPROC_SEQ_FOPS_RO_TYPE(mgc, state);
>
>  LPROC_SEQ_FOPS_WR_ONLY(mgc, ping);
>
> -static int mgc_ir_state_seq_show(struct seq_file *m, void *v)
> -{
> -       return lprocfs_mgc_rd_ir_state(m, m->private);
> -}
> -
>  LPROC_SEQ_FOPS_RO(mgc_ir_state);
>
>  static struct lprocfs_vars lprocfs_mgc_obd_vars[] = {
> --
> 2.1.0
>

I just found out that this is producing errors. Please do not consider this.
Thank you
Shivani
