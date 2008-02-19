From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 19 Feb 2008 13:30:27 +0300
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <47BAAF3F.6030301@sun.com>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
Message-ID: <47BAAFC3.90608@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

hmm. not sure I got it. epoch is per-inode. and we don't need >1 epoch for
any inode.

thanks, Alex

Yuriy Umanets wrote:
> Can we use IAM for storing epoch? It is fast and does not have such 
> strong size limitations. We could make "epoch" index in mkfs time (like 
> it is done for existing indexes now) and use object's fid as a key and 
> epoch as value.
> 
> Thanks.
> 
