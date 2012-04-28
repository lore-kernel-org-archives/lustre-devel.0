From: Liang Zhen <liang@whamcloud.com>
Date: Sat, 28 Apr 2012 16:59:47 +0800
Subject: [Lustre-devel] [wc-discuss] Re: Lustre and cross-platform
	portability
In-Reply-To: <5A40CBC5-F91A-4F34-8209-0C216CCE8A5D@dilger.ca>
References: <5609A4E0-2356-400F-9D53-F71B7007338C@whamcloud.com>
	<5A40CBC5-F91A-4F34-8209-0C216CCE8A5D@dilger.ca>
Message-ID: <BA443C53-9783-4FB2-A755-E63610A90F63@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Apr 27, 2012, at 7:48 AM, Andreas Dilger wrote:
> 
> - there was no objection to converting the Lustre code from spaces
>  to tabs.  My proposal was that build/checkpatch.pl could require
>  tabs immediately, and new patches should be submitted with tabs
>  on all new/modified lines (and optionally all lines on small
>  functions to avoid messy formatting).  This will avoid issues
>  with current patches in flight, and also avoid "git annotate"
>  showing the jumbo replace-all-spaces-with-tabs patch for every
>  line in Lustre, and I think a good fraction of lines will be
>  updated in the next 9-12 months or more.  As we approach the
>  actual time for upstream kernel submission is close, then we can
>  make a final effort to clean up remaining lines in idle code
>  (which will also be unlikely to conflict with existing work).

Lustre also requires to align the first alphabet of members while defining a structure, but linux kernel only aligns any first character (for example, * for pointer), then which way we should choose?
we probably should update our coding guidelines ASAP.

Liang

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120428/8dadc549/attachment.htm>
