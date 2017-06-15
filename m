From: Joe Perches <joe@perches.com>
Date: Thu, 15 Jun 2017 10:04:46 -0700
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: lustre: resolve
 "use spaces between elements" checkpatch errors
In-Reply-To: <alpine.LFD.2.20.1706151748060.11322@casper.infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
	<1497452481-31124-2-git-send-email-jsimmons@infradead.org>
	<1497463820.18751.57.camel@perches.com>
	<alpine.LFD.2.20.1706151700220.11322@casper.infradead.org>
	<1497543584.14396.8.camel@perches.com>
	<alpine.LFD.2.20.1706151748060.11322@casper.infradead.org>
Message-ID: <1497546286.14396.13.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, 2017-06-15 at 17:57 +0100, James Simmons wrote:
> > On Thu, 2017-06-15 at 17:03 +0100, James Simmons wrote:
> > > > On Wed, 2017-06-14 at 11:01 -0400, James Simmons wrote:
> > > > > Due to the way the DFID was embedded in our debug strings checkpatch
> > > > > would report the following error:
> > > > 
> > > > unrelated trivia
> > > > 
> > > > > diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
> > > > 
> > > > []
> > > > > @@ -532,7 +532,7 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
> > > > >  #define FID_NOBRACE_LEN 40
> > > > >  #define FID_LEN (FID_NOBRACE_LEN + 2)
> > > > >  #define DFID_NOBRACE "%#llx:0x%x:0x%x"
> > > > 
> > > > It's odd to use a mixture of %#x and 0x%x.
> > > > 
> > > > Using
> > > > 	#define DFID_NOBRACE "%#llx:%#x:%#x"
> > > > would also save a couple bytes per use.
> > > 
> > > Changing that format would break things very badly. This is used in user 
> > > land utilities and the kernel code. 
> > 
> > Really?  Why would anything break?
> 
> It shouldn't break anything but I'm paranoid.

Which is an entirely different thing than
writing "would break things very badly".

Paranoia is fine, incorrect statements of fact
like that less so.

> In the past I have change 
> "simple" things to have it blow up. I pushed the change to our test 
> harness just to make sure. 

Understandable.

cheers, Joe
