From: Patrick Farrell <paf@cray.com>
Date: Mon, 16 Apr 2018 15:27:58 +0000
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: move stack-check
 macros to libcfs_debug.h
In-Reply-To: <alpine.LFD.2.21.1804160438220.16188@casper.infradead.org>
References: <152383910760.23409.2327082725637657049.stgit@noble>
 <152383935730.23409.6748888065027051683.stgit@noble>
 <alpine.LFD.2.21.1804160438220.16188@casper.infradead.org>
Message-ID: <6D3C7935-E7ED-4826-B459-0C4888D6048E@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

James,

If I understand correctly, you're saying you want to be able to build without debug support...?  I'm not convinced that building a client without debug support is interesting or useful.  In fact, I think it would be harmful, and we shouldn't open up the possibility - this is switchable debug with very low overhead when not actually "on".  It would be really awful to get a problem on a running system and discover there's no debug support - that you can't even enable debug without a reinstall.

If I've understood you correctly, then I would want to see proof of a significant performance cost when debug is built but *off* before agreeing to even exposing this option.  (I know it's a choice they'd have to make, but if it's not really useful with a side order of potentially harmful, we shouldn't even give people the choice.)

- Patrick

?On 4/15/18, 10:49 PM, "lustre-devel on behalf of James Simmons" <lustre-devel-bounces at lists.lustre.org on behalf of jsimmons@infradead.org> wrote:

    
    > CDEBUG_STACK() and CHECK_STACK() are macros to help with
    > debugging, so move them from
    >    drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
    > to
    >    drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
    > 
    > This seems a more fitting location, and is a step towards
    > removing linux/libcfs.h and simplifying the include file structure.
    
    Nak. Currently the lustre client always enables debugging but that
    shouldn't be the case. What we do need is the able to turn off the 
    crazy debugging stuff. In the development branch of lustre it is
    done with CDEBUG_ENABLED. We need something like that in Kconfig
    much like we have CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK. Since we like
    to be able to turn that off this should be moved to just after
    LIBCFS_DEBUG_MSG_DATA_DECL. Then from CHECK_STACK down to CWARN()
    it can be build out. When CDEBUG_ENABLED is disabled CDEBUG_LIMIT
    would be empty.
     
    > Signed-off-by: NeilBrown <neilb@suse.com>
    > ---
    >  .../lustre/include/linux/libcfs/libcfs_debug.h     |   32 ++++++++++++++++++++
    >  .../lustre/include/linux/libcfs/linux/libcfs.h     |   31 -------------------
    >  2 files changed, 32 insertions(+), 31 deletions(-)
    > 
    > diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
    > index 9290a19429e7..0dc7b91efe7c 100644
    > --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
    > +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
    > @@ -62,6 +62,38 @@ int libcfs_debug_str2mask(int *mask, const char *str, int is_subsys);
    >  extern unsigned int libcfs_catastrophe;
    >  extern unsigned int libcfs_panic_on_lbug;
    >  
    > +/* Enable debug-checks on stack size - except on x86_64 */
    > +#if !defined(__x86_64__)
    > +# ifdef __ia64__
    > +#  define CDEBUG_STACK() (THREAD_SIZE -				 \
    > +			  ((unsigned long)__builtin_dwarf_cfa() &       \
    > +			   (THREAD_SIZE - 1)))
    > +# else
    > +#  define CDEBUG_STACK() (THREAD_SIZE -				 \
    > +			  ((unsigned long)__builtin_frame_address(0) &  \
    > +			   (THREAD_SIZE - 1)))
    > +# endif /* __ia64__ */
    > +
    > +#define __CHECK_STACK(msgdata, mask, cdls)			      \
    > +do {								    \
    > +	if (unlikely(CDEBUG_STACK() > libcfs_stack)) {		  \
    > +		LIBCFS_DEBUG_MSG_DATA_INIT(msgdata, D_WARNING, NULL);   \
    > +		libcfs_stack = CDEBUG_STACK();			  \
    > +		libcfs_debug_msg(msgdata,			       \
    > +				 "maximum lustre stack %lu\n",	  \
    > +				 CDEBUG_STACK());		       \
    > +		(msgdata)->msg_mask = mask;			     \
    > +		(msgdata)->msg_cdls = cdls;			     \
    > +		dump_stack();					   \
    > +	      /*panic("LBUG");*/					\
    > +	}							       \
    > +} while (0)
    > +#define CFS_CHECK_STACK(msgdata, mask, cdls)  __CHECK_STACK(msgdata, mask, cdls)
    > +#else /* __x86_64__ */
    > +#define CFS_CHECK_STACK(msgdata, mask, cdls) do {} while (0)
    > +#define CDEBUG_STACK() (0L)
    > +#endif /* __x86_64__ */
    > +
    >  #ifndef DEBUG_SUBSYSTEM
    >  # define DEBUG_SUBSYSTEM S_UNDEFINED
    >  #endif
    > diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
    > index 07d3cb2217d1..83aec9c7698f 100644
    > --- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
    > +++ b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
    > @@ -80,35 +80,4 @@
    >  #include <stdarg.h>
    >  #include "linux-cpu.h"
    >  
    > -#if !defined(__x86_64__)
    > -# ifdef __ia64__
    > -#  define CDEBUG_STACK() (THREAD_SIZE -				 \
    > -			  ((unsigned long)__builtin_dwarf_cfa() &       \
    > -			   (THREAD_SIZE - 1)))
    > -# else
    > -#  define CDEBUG_STACK() (THREAD_SIZE -				 \
    > -			  ((unsigned long)__builtin_frame_address(0) &  \
    > -			   (THREAD_SIZE - 1)))
    > -# endif /* __ia64__ */
    > -
    > -#define __CHECK_STACK(msgdata, mask, cdls)			      \
    > -do {								    \
    > -	if (unlikely(CDEBUG_STACK() > libcfs_stack)) {		  \
    > -		LIBCFS_DEBUG_MSG_DATA_INIT(msgdata, D_WARNING, NULL);   \
    > -		libcfs_stack = CDEBUG_STACK();			  \
    > -		libcfs_debug_msg(msgdata,			       \
    > -				 "maximum lustre stack %lu\n",	  \
    > -				 CDEBUG_STACK());		       \
    > -		(msgdata)->msg_mask = mask;			     \
    > -		(msgdata)->msg_cdls = cdls;			     \
    > -		dump_stack();					   \
    > -	      /*panic("LBUG");*/					\
    > -	}							       \
    > -} while (0)
    > -#define CFS_CHECK_STACK(msgdata, mask, cdls)  __CHECK_STACK(msgdata, mask, cdls)
    > -#else /* __x86_64__ */
    > -#define CFS_CHECK_STACK(msgdata, mask, cdls) do {} while (0)
    > -#define CDEBUG_STACK() (0L)
    > -#endif /* __x86_64__ */
    > -
    >  #endif /* _LINUX_LIBCFS_H */
    > 
    > 
    > 
    _______________________________________________
    lustre-devel mailing list
    lustre-devel at lists.lustre.org
    http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
    
