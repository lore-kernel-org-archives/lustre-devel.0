From: James Simmons <jsimmons@infradead.org>
Date: Tue, 1 Oct 2019 18:52:16 +0100 (BST)
Subject: [lustre-devel] [PATCH 001/151] lnet: fix needed headers for
 lnet headers
In-Reply-To: <87d0fh6i8e.fsf@notabene.neil.brown.name>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
 <1569869810-23848-2-git-send-email-jsimmons@infradead.org>
 <87d0fh6i8e.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1910011851520.9239@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Mon, Sep 30 2019, James Simmons wrote:
> 
> > The linux kernel now has a sanity check for the global headers,
> > activated by  CONFIG_HEADER_TEST=y and CONFIG_KERNEL_HEADER_TEST=y.
> > Some LNet headers are missing a few headers to allow them to build
> > properly.
> >
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > Signed-off-by: NeilBrown <neilb@suse.com>
> 
> I've added the following to this patch
> 
> diff --git a/include/linux/libcfs/libcfs_debug.h b/include/linux/libcfs/libcfs_debug.h
> index 911fd35b81b5..2ae67c67faa7 100644
> --- a/include/linux/libcfs/libcfs_debug.h
> +++ b/include/linux/libcfs/libcfs_debug.h
> @@ -56,6 +56,8 @@ extern unsigned int libcfs_console_backoff;
>  extern unsigned int libcfs_debug_binary;
>  extern char libcfs_debug_file_path_arr[PATH_MAX];
>  
> +struct task_struct;
> +
>  int libcfs_debug_mask2str(char *str, int size, int mask, int is_subsys);
>  int libcfs_debug_str2mask(int *mask, const char *str, int is_subsys);
>  void libcfs_debug_dumpstack(struct task_struct *tsk);
> 
> 
> NeilBrown

Acked-by: James Simmons <jsimmons@infradead.org> 
