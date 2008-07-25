From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Fri, 25 Jul 2008 16:29:07 +0400
Subject: [Lustre-devel] statahead feature
In-Reply-To: <1216978676.16594.104.camel@bear.shadowland>
References: <4888573F.4010506@sun.com> <488957EC.1040701@sun.com>
	<4889597A.6060109@sun.com> <1216978676.16594.104.camel@bear.shadowland>
Message-ID: <4889C713.7050801@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alex Lyashkov wrote:
> this looks easy to implement - call ll_readdir with i_mutex held and
> pass custom fill callback.
> in callback we allocate new dentry + empty locked inode (or attach new
> dentry to inode if we have only update lock /ll_find_alias/ ?? ), also
> submit async getattr rpc into ptlrpcd if need.
> rpc completion callback set md_lock to inode and unlock inode.
> also ll_getattr_it should call wait_on_inode for be sure statahead is
> finished.

I think it'd be better to get common infrastructure in ll_lookup_it()
which can resolve name to fid from readdir's cache. having that in lookup
path means any syscall can benefit from it, not statahead only.

for example, we can do open by fid on mds and mds won't need to resolve
name by himself.

probably, this infrastructure could be used for WBC.

thanks, Alex
