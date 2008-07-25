From: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Fri, 25 Jul 2008 12:37:56 +0300
Subject: [Lustre-devel] statahead feature
In-Reply-To: <4889597A.6060109@sun.com>
References: <4888573F.4010506@sun.com> <488957EC.1040701@sun.com>
	<4889597A.6060109@sun.com>
Message-ID: <1216978676.16594.104.camel@bear.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, 2008-07-25 at 08:41 +0400, Alex Zhuravlev wrote:

> 
> > Another optimization (maybe) to be considered is that whether it is 
> > necessary to start one statahead thread
> > for each "ls -l" operation or not? As said by Nikita, maybe we can use a 
> > single thread for all the statahead.
> 
> I'm not sure we need any statahead thread at all. what's wrong with issuing
> number of async RPCs from ll_getattr_it()? this way user's application drives
> statahead directly: each time stat(2) is called you tune statahead window and
> send few more RPCs again -- like data read-ahead does.
> 
not need any statahead thread.
as alex say:
if we have UPDATE lock to parent - we can create valid dentry without
lookup and add new locked inode to him.
---
this looks easy to implement - call ll_readdir with i_mutex held and
pass custom fill callback.
in callback we allocate new dentry + empty locked inode (or attach new
dentry to inode if we have only update lock /ll_find_alias/ ?? ), also
submit async getattr rpc into ptlrpcd if need.
rpc completion callback set md_lock to inode and unlock inode.
also ll_getattr_it should call wait_on_inode for be sure statahead is
finished.



-- 
Alex Lyashkov <Alexey.lyashkov@sun.com>
Lustre Group, Sun Microsystems
