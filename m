From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Mon, 19 Sep 2016 09:05:43 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: lmv: add missing
	function declaration
In-Reply-To: <alpine.LFD.2.20.1609182152220.31599@casper.infradead.org>
References: <1474198793-25108-1-git-send-email-baoyou.xie@linaro.org>
	<alpine.LFD.2.20.1609182035370.31599@casper.infradead.org>
	<2318806.4yLNEl44ta@wuerfel>
	<alpine.LFD.2.20.1609182152220.31599@casper.infradead.org>
Message-ID: <CA+DQWkyX2xqhZ1CSHV_NZ_B1jp_OHnpPRuZeqG14XrdBPh4pwg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 19 September 2016 at 04:53, James Simmons <jsimmons@infradead.org> wrote:

>
> > On Sunday, September 18, 2016 8:43:18 PM CEST James Simmons wrote:
> > >
> > > Nak. I'm not seeing this error with W=1. Also if you look
> > > lmv_pack_md() is only used in lmv_obd.c and the function
> > > appears early in the file before it is used, so no prototype
> > > missing errors should happen.
> >
> > So it should be marked "static" and the EXPORT_SYMBOL() removed,
> > right?
>
> Already done. See patch
>
>
I worked with linux-next branch, if it have been done in your tree, just
ignore it.


> [PATCH 109/124] staging: lustre: misc: remove unnecessary EXPORT_SYMBOL
>
> which is from Frank Zago which I just pushed to Greg.
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160919/dd3f61ce/attachment.htm>
