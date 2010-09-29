From: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Date: Wed, 29 Sep 2010 15:01:56 -0400
Subject: [Lustre-devel] Large readdir RPCs project
In-Reply-To: <4CA2EE55.7010209@whamcloud.com>
References: <AANLkTin42fMZpZ-eRt6gF__Ftw6Oo5BBf58Mb-376erW@mail.gmail.com>
	<4CA2EE55.7010209@whamcloud.com>
Message-ID: <AANLkTi=q2XwYnhWPRUJha-o8dxCV5DZ6_so_P5RbHzN4@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>
>
> On the other hand, Large readdir RPCs is basic of another metadata read
> performance improvement features - "readdir+", which is quite useful for "ls
> -l" operation (for large directory), and reduce lookup/getattr RPC as much
> as possible. In such feature, MDS will pack more dir-item's attribute (not
> only name/ino as does currently by readdir, but also mode/owner, and etc)
> information back to client-side in "readdir+" RPC. That means the dir-item
> count in one "readdir+" page is less than in the traditional readdir page,
> then more pages to be sent back to client. If without "Large readdir RPCs",
> the advantage of "readdir+" will be discounted.
>

I'd be interested in working this as well but probably as a separate
effort since SOM isn't in 1.8 and that's my main focus.  In our testing, SOM
had significant benefits over the WAN and I'd expect even better from
readdir+.  I have tried Oleg's patch for asynchronous ll_glimpse_size but
oddly I've seen someone erradic performance where at times it was worse then
statahead and synchronous ll_glimpse_size.

Jeremy
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100929/91a1e011/attachment.htm>
