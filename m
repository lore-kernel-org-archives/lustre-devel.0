From: Patrick Farrell <paf@cray.com>
Date: Fri, 16 Nov 2018 18:06:41 +0000
Subject: [lustre-devel] Compact layouts
Message-ID: <3600968B-94D3-4C3F-857A-D00A5C3BC601@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All,

There is an old idea for reducing the data required to describe file striping by using a bitmap to record which OSTs are in use.  As best I can tell, this was most recently described here:
http://wiki.lustre.org/Layout_Enhancement_Solution_Architecture#Compact_Layouts_2

I?m curious if this has been pursued any further, if there?s a JIRA or other place that might have more info or be tracking the idea.  I poked around and didn?t find anything.

In particular, this comment:
?with enough data that for each OST index set in the bitmap, a corresponding OST object FID may be computed?
Points at the difficult part of implementing this.

So, before I get too far considering this problem - Is there more out there somewhere?  Hoping to avoid duplicating work!

Thanks,

  *   Patrick
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181116/cb32f66b/attachment.html>
