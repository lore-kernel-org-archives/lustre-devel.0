From: Fan Yong <yong.fan@whamcloud.com>
Date: Wed, 29 Sep 2010 15:44:21 +0800
Subject: [Lustre-devel] Large readdir RPCs project
In-Reply-To: <AANLkTin42fMZpZ-eRt6gF__Ftw6Oo5BBf58Mb-376erW@mail.gmail.com>
References: <AANLkTin42fMZpZ-eRt6gF__Ftw6Oo5BBf58Mb-376erW@mail.gmail.com>
Message-ID: <4CA2EE55.7010209@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

  According to bug 17833 
(https://bugzilla.lustre.org/show_bug.cgi?id=17833) comment #0, as 
Andreas' pointed out, the existing lustre framework almost supports bulk 
readdir RPCs on server-side. The mainly work to be done is on 
client-side to make llite/MDC to trigger multiple pages reading each 
time instead of single page of readdir().

Just as your first idea, it is quite possible to be used as the 
implementation, which is relative simple and efficient.

On the other hand, Large readdir RPCs is basic of another metadata read 
performance improvement features - "readdir+", which is quite useful for 
"ls -l" operation (for large directory), and reduce lookup/getattr RPC 
as much as possible. In such feature, MDS will pack more dir-item's 
attribute (not only name/ino as does currently by readdir, but also 
mode/owner, and etc) information back to client-side in "readdir+" RPC. 
That means the dir-item count in one "readdir+" page is less than in the 
traditional readdir page, then more pages to be sent back to client. If 
without "Large readdir RPCs", the advantage of "readdir+" will be 
discounted.


Cheers,
Nasf

On 9/28/10 9:14 PM, Jeremy Filizetti wrote:
> Since I work mostly with Lustre over a WAN I'd definitely like to see 
> the larger readdir RPCs in Lustre to save on RTTs between clients and 
> the MDS.  I'm just looking for some input to make sure I'm looking at 
> the right changes.  I know Andreas had mentioned an issue with larger 
> pages to me at LUG this year.
>
> From the description I'm guessing the approach would be to request 
> additioinal pages in the ll_dir_readpage similar to how read ahead is 
> handled in ll_readpage.  mdc_readpage also needs to be changed to 
> handle multiple pages and prep each page for bulk.  I think this makes 
> the most sense because at least by default I see getdents64 only be 
> called with a 4k buffer.  Otherwise it might make sense to change the 
> ll_readdir functions to handle more pages and ll_get_dir_page to 
> request additional pages and call read_cache_pages instead.
>
> Jeremy
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100929/10c1fa34/attachment.htm>
