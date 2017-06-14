From: Joe Perches <joe@perches.com>
Date: Wed, 14 Jun 2017 11:10:20 -0700
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: lustre: resolve
 "use spaces between elements" checkpatch errors
In-Reply-To: <1497452481-31124-2-git-send-email-jsimmons@infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
	<1497452481-31124-2-git-send-email-jsimmons@infradead.org>
Message-ID: <1497463820.18751.57.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, 2017-06-14 at 11:01 -0400, James Simmons wrote:
> Due to the way the DFID was embedded in our debug strings checkpatch
> would report the following error:

unrelated trivia

> diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
[]
> @@ -532,7 +532,7 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
>  #define FID_NOBRACE_LEN 40
>  #define FID_LEN (FID_NOBRACE_LEN + 2)
>  #define DFID_NOBRACE "%#llx:0x%x:0x%x"

It's odd to use a mixture of %#x and 0x%x.

Using
	#define DFID_NOBRACE "%#llx:%#x:%#x"
would also save a couple bytes per use.

Does there need to be a difference between an SFID
and a DFID_NOBRACE?
