From: Yuriy Umanets <yuriy.umanets@clusterstor.com>
Date: Thu, 22 Apr 2010 14:42:55 +0300
Subject: [Lustre-devel] about lustre lock
In-Reply-To: <q2id272ddfb1004210106w4170f6fcja89d40c2e99a1333@mail.gmail.com>
References: <q2id272ddfb1004210106w4170f6fcja89d40c2e99a1333@mail.gmail.com>
Message-ID: <r2x3ed212d01004220442n6dad8e6fr241f75916cdbd47e@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

hello,

I think this is used in parallel dir operations in 2.0 branch. In this case
we allow multiple threads to modify the same dir if entries fall into
different physical blocks (and take care about locking on lower layers in
MDS if entries come to the same block). But as this is a dir modification
operation, we want to let clients know about this, so that they can flush
their dentry cache.

Thanks.

2010/4/21 Tonney Kaiven Cheung <zhangys04@gmail.com>

> Dear everyone!
>
> It has been said that Lustre Filesystem has six lock modes. And one of the
> lock mode is *concurrent write mode*. Would you please give me explanation
> that in which condition a *concurrent write mode lock* will be asked?
> Thanks!
>
> Yuksam Cheung
> 2010-04-21
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
>


-- 
umka
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100422/183de366/attachment.htm>
