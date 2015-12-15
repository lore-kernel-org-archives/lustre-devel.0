From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Dec 2015 21:19:32 +0300
Subject: [lustre-devel] [PATCH 13/40] staging: lustre: Dynamic LNet
 Configuration (DLC) show command
In-Reply-To: <944b6e806bc44a3fa4d6d5e1904a894a@EXCHCS32.ornl.gov>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-14-git-send-email-jsimmons@infradead.org>
	<20151202112055.GM18797@mwanda>
	<944b6e806bc44a3fa4d6d5e1904a894a@EXCHCS32.ornl.gov>
Message-ID: <20151215181932.GH5177@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Dec 15, 2015 at 06:14:19PM +0000, Simmons, James A. wrote:
>   
> >>  struct libcfs_ioctl_hdr {
> >>  	__u32 ioc_len;
> >> @@ -87,6 +88,13 @@ do {						    \
> >>  	data.ioc_hdr.ioc_len = sizeof(data);			\
> >>  } while (0)
> >>  
> >> +#define LIBCFS_IOC_INIT_V2(data, hdr)			\
> >> +do {							\
> >> +	memset(&(data), 0, sizeof(data));		\
> >> +	(data).hdr.ioc_version = LIBCFS_IOCTL_VERSION2;	\
> >> +	(data).hdr.ioc_len = sizeof(data);		\
> >> +} while (0)
> >> +
> >
> >Do we really need this?
> 
> Would you be okay if this was a inline function? This is used by user land and kernel space code.
> 

I try (not very hard) to sound like a broken record but this business of
sharing code with userland is a pain in the butt.  It's not used in the
kernel or in any patches you have sent.

It would look better as an inline function though so I wouldn't have
even noticed it.

regards,
dan carpenter
