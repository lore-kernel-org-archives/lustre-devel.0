From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 15 Dec 2015 18:39:07 +0000
Subject: [lustre-devel] [PATCH 13/40] staging: lustre: Dynamic LNet
 Configuration (DLC) show command
In-Reply-To: <20151215181932.GH5177@mwanda>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-14-git-send-email-jsimmons@infradead.org>
	<20151202112055.GM18797@mwanda>
	<944b6e806bc44a3fa4d6d5e1904a894a@EXCHCS32.ornl.gov>
	<20151215181932.GH5177@mwanda>
Message-ID: <5a754fcb1c2f42cba72b558e41d03828@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>On Tue, Dec 15, 2015 at 06:14:19PM +0000, Simmons, James A. wrote:
>>   
>> >>  struct libcfs_ioctl_hdr {
>> >>  	__u32 ioc_len;
>> >> @@ -87,6 +88,13 @@ do {						    \
>> >>  	data.ioc_hdr.ioc_len = sizeof(data);			\
>> >>  } while (0)
>> >>  
>> >> +#define LIBCFS_IOC_INIT_V2(data, hdr)			\
>> >> +do {							\
>> >> +	memset(&(data), 0, sizeof(data));		\
>> >> +	(data).hdr.ioc_version = LIBCFS_IOCTL_VERSION2;	\
>> >> +	(data).hdr.ioc_len = sizeof(data);		\
>> >> +} while (0)
>> >> +
>> >
>> >Do we really need this?
>> 
>> Would you be okay if this was a inline function? This is used by user land and kernel space code.
>> 
>
>I try (not very hard) to sound like a broken record but this business of
>sharing code with userland is a pain in the butt.  It's not used in the
>kernel or in any patches you have sent.
>
>It would look better as an inline function though so I wouldn't have
>even noticed it.

I'm glad you noticed.  I just looked at the production source code and yep it is only used
in the userland tools code. I need to update our tools so they don't break. Then we can
remove these macros.
