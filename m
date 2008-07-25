From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Fri, 25 Jul 2008 08:44:22 +0400
Subject: [Lustre-devel] statahead feature
In-Reply-To: <488957EC.1040701@sun.com>
References: <4888573F.4010506@sun.com> <488957EC.1040701@sun.com>
Message-ID: <48895A26.8010006@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yong Fan wrote:
> Lockless getattr RPC for "ls -l" is a good idea. But whether all the 
> getattr RPC will be lockless or not?

forgot to answer this ...

I believe it's to be decided by the server who knows how given inode is contended.
we do the same for i_size in glimpse path.

thanks, Alex
