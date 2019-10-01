From: James Simmons <jsimmons@infradead.org>
Date: Tue, 1 Oct 2019 18:54:29 +0100 (BST)
Subject: [lustre-devel] [PATCH 069/151] lustre: ptlrpc: use lu_extent in
 layout_intent
In-Reply-To: <87o8z16t95.fsf@notabene.neil.brown.name>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
 <1569869810-23848-70-git-send-email-jsimmons@infradead.org>
 <87o8z16t95.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1910011852440.9239@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > From: Jinshan Xiong <jinshan.xiong@gmail.com>
> >
> > This way it will be easier to check and print the extent
> > of layout.
> >
> > WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
> > Lustre-commit: c1f450270dda ("LU-9971 ptlrpc: use lu_extent in layout_intent")
> > Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
> > Reviewed-on: https://review.whamcloud.com/29087
> > Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
> > Reviewed-by: Bobi Jam <bobijam@hotmail.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  include/uapi/linux/lustre/lustre_idl.h  | 3 +--
> >  include/uapi/linux/lustre/lustre_user.h | 2 +-
> >  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> 
> hi James,
>  most of this patch is missing - it seems to have been merged into the
>  next patch by mistake.
>  I'm walking through patches checking that code still compiles after
>  each patch, and this one doesn't.
> 
> NeilBrown

Ugh. My tree is on a NFS partition so some times when I apply a patch 
while on one node the entire change doesn't show up on another node.
Do you need me to resend the patch?
 
> >
> > diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
> > index a088f4a..b4f7aec 100644
> > --- a/include/uapi/linux/lustre/lustre_idl.h
> > +++ b/include/uapi/linux/lustre/lustre_idl.h
> > @@ -2825,8 +2825,7 @@ enum {
> >  struct layout_intent {
> >  	__u32 li_opc;	/* intent operation for enqueue, read, write etc */
> >  	__u32 li_flags;
> > -	__u64 li_start;
> > -	__u64 li_end;
> > +	struct lu_extent li_extent;
> >  } __packed;
> >  
> >  /**
> > diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
> > index 7d9f0d2..d4372d9 100644
> > --- a/include/uapi/linux/lustre/lustre_user.h
> > +++ b/include/uapi/linux/lustre/lustre_user.h
> > @@ -426,7 +426,7 @@ struct lu_extent {
> >  	__u64	e_end;
> >  };
> >  
> > -#define DEXT "[ %#llx , %#llx )"
> > +#define DEXT "[%#llx, %#llx)"
> >  #define PEXT(ext) (ext)->e_start, (ext)->e_end
> >  
> >  static inline bool lu_extent_is_overlapped(struct lu_extent *e1,
> > -- 
> > 1.8.3.1
> 
